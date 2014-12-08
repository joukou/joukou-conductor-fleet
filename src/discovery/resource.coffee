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

class DiscoveryResource
  name: ""
  methods: []
  client: null
  ###*
  * @param {string} name
  * @param {Array.<DiscoveryMethod>} methods
  ###
  constructor: (name, methods, client) ->
    this.name = name
    this.methods = methods
    this.client = client
    this._attachMethods()
  _attachMethods: ->
    for methodName of this.methods
      if not this.methods.hasOwnProperty(methodName)
        continue
      this._attachMethod(methodName)
  _attachMethod: (methodName) ->
    this[methodName] = this.wrapCallMethod(methodName)
  wrapCallMethod: (methodName) ->
    resource = this
    return ->
      method = resource.methods[methodName]
      method.callMethod.apply(method, arguments)
  getMethod: (name) ->
    return this.methods[name]
  hasMethod: (name) ->
    return !!this.methods[name]

module.exports = DiscoveryResource