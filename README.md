# DroneSimulator

## Running The Application
To run the application you have two options 
1. If you have latest version of elixir and OTP installed then.

run the app with command

```
iex -S mix
```

2. In case you don't want to install elixir and OTP yourself you can use 
the docker version and run the following command.
```
docker-compose -f docker/docker-compose.yml run drone_simulator
```

Both the above mentioned commands run the application in interactive shell
mode.

## Application and Details

### Problem Statement

Write a simulation that has one dispatcher and two drones. Each drone should 
"move" independently on different processes. The dispatcher should send the 
coordinates to each drone detailing where the drone's next position should be. 
The dispatcher should also be responsible for terminating the program. 
When the drone receives a new coordinate, it moves, checks if there is a tube 
station in the area, and if so, reports on the traffic conditions there. 

** Things to Note **
- The simulation should finish @ 08:10, where the drones will receive a 
  "SHUTDOWN" signal.
- The two drones have IDs 6043 and 5937. There is a file containing their 
  lat/lon points for their routes. The csv file layout is drone id,latitude,
  longitude,time
- There is also a file with the lat/lon points for London tube stations.
  station,lat,lon
- Traffic reports should have the following format:
    - Drone ID
    - Time
    - Speed
    - Conditions of Traffic (HEAVY, LIGHT, MODERATE). This can be chosen 
      randomly.

** Important Remarks **
  - A nearby station should be less than 350 meters from the drone's position.
  - Bonus point: Put a constraint on each drone to have limited memory, 
    so they can only consume ten points at a time.

----------

## Application Design

The entire application can be sub-divided into three parts:
- `Control`: Handles the ticker, dispatcher and consumer processes. 
- `Drone`: Handles data related to drones and holds helper modules
         to handle drone related functionalities.
- `Tube`: Handles data and helper modules related to Tube Stations.

### Supervision Tree

#### Application

  | - Application 
    |-- DroneSimulator.DroneDataSupervisor
        |-- drone_id_1
        |-- drone_id_2
            .
            .
        |-- drone_id_n
    |-- DroneSimulator.Tube.DataAgent


At the start of the application supervision tree starts `DroneDataSupervisor` 
and tube data agent. 
The `DroneDataSupervisor` is responsible for starting agents for each `drone_id`
configured in the application. 
`/config/config.exs`

```
config :drone_simulator,
  drone_ids: [5937, 6043]
```
It starts one agent for each `id` in the `drone_ids` list and supervises it 
using `:one_for_one` strategy.

The `DroneSimulator.Tube.DataAgent` starts an agent for holding tube station 
data. The data strucuture used by the agent is a `quadtree` to hold all the 
co-ordinates for different stations. A `quadtree` is being used here as it 
allows efficient search for nearest neighbours, given a set of location 
co-oridnates.

#### Control Supervisor

The control supervisor `DroneSimulator.ControlSupervisor`, starts after user 
confirmation to start the simulator.

  | -- `DroneSimulator.ControlSupervisor`
      | -- `DroneSimulator.Control.Timer`
      | -- `DroneSimulator.Control.Dispatcher`
      | -- `drone_process_id_1`
      | -- .
           .
           .
      | --`drone_process_id_n`

Upon user confirmation the `DroneSimulator.ControlSupervisor` starts, the timer
process, a dispatcher and multiple drone_processes depending on the drone ids 
configured in the application. The strategy used here is `:rest_for_one` so as 
to provide the required fault tolerance.

To implement the communication between dispatcher, `DroneSimulator.Control.Dispatcher`
and `drone_processes` elixir's `GenStage` behaviour is used. This was done
keeping in mind the requirement of memory limit on drone processes. GenStage
provides a backpressure mechanism where consumer processes(here drone_processes)
can limit the number of events being sent by the 
producer(`DroneSimulator.Control.Dispatcher`).

The Dispatcher here uses the `GenStage.BroadcastDispatcher` to dispatch events.
This behaviour allows the consumer processes to subscribe to events specific
to them. Here the filtering for events is being done based on the `drone_id`.
This allows `drone_processes` to run independently and in isolation.

__configurations__
```
config :drone_simulator,
  timer_start_date_time: "2011-03-22 07:55:00",
  timer_end_date_time: "2011-03-22 08:15:00",
  ticking_cycle: 10_000
```
The ticking cycle(in milliseconds) here controls the speed of the timer which 
basically ticks to the next minute in specified time. 
See `/lib/drone_simulator/control/timer.ex`.
