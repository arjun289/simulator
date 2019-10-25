defmodule DroneSimulator do
  alias DroneSimulator.ControlSupervisor

  @doc """
  Starts the drone simulator based on user input.
  """
  def start_simulator() do
    input =
      IO.ANSI.green()
      <> "Would you like to start Simulation (y/n): "
      <> IO.ANSI.reset()
      |> IO.gets()

    check_input(input)
  end

  ################### private functiions ###############

  defp check_input({:error, reason}) do
    IO.puts("Some error occured! #{reason}")
    exit(:normal)
  end

  defp check_input(:eof) do
    IO.puts("EOF!")
    exit(:normal)
  end

  defp check_input(input) do
    input = input |> String.trim() |> String.downcase()
    start_application(input)
  end

  defp start_application("y") do
    ControlSupervisor.start_link(nil)
  end

  defp start_application(_) do
    IO.puts(
      IO.ANSI.red()
      <> "Dispatcher not started!"
      <> IO.ANSI.reset()
    )
    Process.sleep(1000)
    start_simulator()
  end
end
