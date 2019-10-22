# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

use Mix.Config

config :drone_simulator,
  drone_ids: [5937, 6043]

# configures the start time, end time and ticking cycle
# for the timer. The ticking cycle makes the simulation run
# or slow. A tick moves the timer to next minute in the time
# specified which is in ms.Please don't confuse this with
# a normal clock, the functionality here is just for simulation.

config :drone_simulator,
  timer_start_date_time: "2011-03-22 07:55:26",
  timer_end_date_time: "2011-03-22 08:10:00",
  ticking_cycle: 30_000
