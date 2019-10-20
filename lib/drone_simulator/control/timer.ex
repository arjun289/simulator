defmodule DroneSimulator.Control.Timer do
  @moduledoc """
  Timer Module to create clock events.

  The timer modules a dummy clock which generates events.
  These events are used by dispatcher to dispatch events at
  a particular interval.
  """

  use GenServer
  alias DroneSimulator.Control.Dispatcher

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      initial_args(),
      name: __MODULE__
    )
  end

  ##################### server calls #################

  def init(params) do
    initial_state = Map.put(params, :current_time, params.start_time)
    run_ticker(initial_state)
    {:ok, initial_state}
  end

  def handle_info(:tick, state) do
    current_time = Timex.shift(state.current_time, minutes: 1)
    new_state = Map.put(state, :current_time, current_time)
    IO.inspect(new_state.current_time)
    Dispatcher.event_dispatch(new_state.current_time)

    run_ticker(new_state)

    {:noreply, new_state}
  end


  ################### private functions ##############

  defp run_ticker(state) do
    Process.send_after(self(), :tick, state.ticking_cycle)
  end

  defp initial_args() do
    start_time =
      :drone_simulator
      |> Application.get_env(:timer_start_date_time)
      |> Timex.parse!("%F %T", :strftime)

    end_time =
      :drone_simulator
      |> Application.get_env(:timer_end_date_time)
      |> Timex.parse!("%F %T", :strftime)

    ticking_cycle = Application.get_env(:drone_simulator, :ticking_cycle)

    %{start_time: start_time, end_time: end_time, ticking_cycle: ticking_cycle}
  end
end
