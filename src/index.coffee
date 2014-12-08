###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

###*
@module joukou-conductor/fleet/index
###

Q         = require("q")
discovery = require("./discovery/client")

class FleetClient
  ###*
  @type {DiscoveryClient}
  ###
  discoveryClient: null
  constructor: (endpoint, basePath, doDiscovery) ->
    this.discoveryClient = discovery.getClient(endpoint, basePath, false)
    if doDiscovery
      this.discoveryClient.doDiscovery()
    return this
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#create-a-unit
  createUnit: (name, options, desiredState, currentState, machineID) ->
    ###
      parameters:
        unitName: string
          required
      request:
        $ref: Unit
        schema: object
          properties:
            name:string
            options: array
              items:
                $ref: UnitOptions
                schema:
                  section: string
                  name: string
                  value: string
            desiredState: string
            currentState: string
            machineID: string
              required
    ###
    this.discoveryClient
      .on.method("Unit", "Set", [
        {
        unitName: name
        },
        {
          name: name
          options: options
          desiredState: desiredState
          currentState: currentState
          machineID: machineID
        }
      ])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#modify-desired-state-of-a-unit
  setUnitDesiredState: (name, desiredState, machineID) ->
    ###
      parameters:
        unitName: string
          required
      request:
        $ref: Unit
        schema: object
          properties:
            desiredState: string
            machineID: string
              required
    ###
    this.discoveryClient
      .on.method("Unit", "Set", [
        {
          unitName: name
        },
        {
          desiredState: desiredState
          machineID: machineID
        }
      ])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#retrieve-desired-state-of-a-specific-unit
  getUnitDesiredState: (name) ->
    ###
      parameters:
        unitName: string
          required
    ###
    this.discoveryClient
      .on.method("Unit", "Get", [
        {
          unitName: name
        }
      ])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#retrieve-desired-state-of-all-units
  getUnitDesiredStates: ->
    this.discoveryClient
      .on.method("UnitStates", "List", [])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#destroy-a-unit
  destroyUnit: (unitName) ->
    ###
      parameters:
        unitName: string
          required
    ###
    this.discoveryClient
      .on.method("Unit", "Delete", [
        {
          unitName: unitName
        }
      ])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#retrieve-current-state-of-all-units
  getMachineStates: (machineID) ->
    return this.getStates(
      machineID: machineID
    )
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#retrieve-current-state-of-all-units
  getUnitStates: (unitName) ->
    return this.getStates(
      unitName: unitName
    )
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#retrieve-current-state-of-all-units
  getStates: (opts) ->
    this.discoveryClient
      .on.method("UnitStates", "List", [opts])
  # https://github.com/coreos/fleet/blob/master/Documentation/api-v1-alpha.md#list-machines
  getMachines: ->
    this.discoveryClient
      .on.method("Machines", "List", [])

module.exports =
  getClient: (endpoint, basePath, doDiscovery) ->
    new FleetClient(endpoint, basePath, doDiscovery)