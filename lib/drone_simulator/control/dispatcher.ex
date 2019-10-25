defmodule DroneSimulator.Control.Dispatcher do
  @moduledoc """
  Module to handle event dispatching.

  This module receives events from the timer on every tick.
  On receiving an event, it queries the drone agent holding the
  co-ordinate and timing data for events that need to be processed
  and dispatches it to drone consumer processes.
  """

  @stop_time Time.from_erl!({08, 10, 00})

  use GenStage
  alias DroneSimulator.Drone
  alias DroneSimulator.ControlSupervisor
  alias DroneSimulator

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(drone_ids) do
    IO.ANSI.color(53)
    <> "Initializing Event Dispatcher... "
    <> IO.ANSI.reset()
    |> IO.puts()

    GenStage.start_link(__MODULE__, drone_ids, name: __MODULE__)
  end

  @spec event_dispatch(any) :: :ok
  def event_dispatch(event) do
    GenStage.cast(__MODULE__, {:notify, event})
  end

  #################### server callbacks ################

  def init(drone_ids) do
    drone_agents = Enum.map(drone_ids, fn drone_id ->
      String.to_atom("drone_agent_" <> to_string(drone_id))
    end)

    {
      :producer,
      %{events: [], demand: 0, agents: drone_agents},
      dispatcher: GenStage.BroadcastDispatcher
    }
  end

  def handle_cast({:notify, time_event}, state) do
    handle_tick_event(stop_event_processing?(time_event), time_event, state)
  end

  def handle_demand(incoming_demand, state) do
    %{events: events, demand: pending_demand, agents: drone_agents} = state
    dispatch_events(events, incoming_demand + pending_demand, drone_agents)
  end

  ################## private functions ####################

  defp stop_event_processing?(time) do
    time
    |> NaiveDateTime.to_time()
    |> Time.compare(@stop_time)
    |> case do
      :eq ->
        true
      _ ->
        false
    end
  end

  defp handle_tick_event(true, _time_event, _state) do
    IO.puts(IO.ANSI.red() <> "Stopping Simulation!" <> IO.ANSI.reset())
    Supervisor.stop(ControlSupervisor)
    Process.sleep(2000)
    DroneSimulator.start_simulator()
  end

  defp handle_tick_event(false, time_event, state) do
    %{events: events, agents: drone_agents} = state

    IO.inspect("Generate events for time #{inspect(time_event)}")
    time_event = Timex.shift(time_event, minutes: 1)
    new_events = get_events(time_event, events, drone_agents)
    {:noreply, events, Map.put(state, :events, new_events)}
  end

  defp dispatch_events(events, demand = 0, drone_agents) do
    {:noreply, [], %{events: events, demand: demand, agents: drone_agents}}
  end

  defp dispatch_events([], demand, drone_agents) do
    {:noreply, [], %{events: [], demand: demand, agents: drone_agents}}
  end

  defp dispatch_events(events, demand, drone_agents) do
    {events_to_dispatch, remaining_events} = Enum.split(events, demand)
    new_state = %{events: remaining_events, demand: 0, agents: drone_agents}
    {:noreply, events_to_dispatch, new_state}
  end

  defp get_events(time_event, events, drone_agents) do
    Enum.reduce(drone_agents, events, fn agent, acc ->
      data = Drone.DataAgent.pop_events(agent, time_event)
      acc ++ data
    end)
  end

end
