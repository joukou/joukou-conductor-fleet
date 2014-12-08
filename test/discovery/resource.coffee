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

proxyquire        = require("proxyquire")

DiscoveryResource = require( '../../dist/discovery/resource')
assert            = require( 'assert' )
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use(chaiAsPromised)
expect            = chai.expect

describe "resource", ->
  specify "methods attach", ->
    resource = new DiscoveryResource("name", {
      methodName: {
        callMethod: ->

      }
    }, {})
    expect(resource).to.include.key("methodName")

  specify "methods are called", ->
    methodCalled = false
    resource = new DiscoveryResource("name", {
      methodName: {
        callMethod: ->
          methodCalled = true
      }
    }, {})
    resource.methodName()
    expect(methodCalled).to.be.ok

  specify "methods are called with parameters", ->
    methodCalled = false
    resource = new DiscoveryResource("name", {
      methodName: {
        callMethod: (a, b, c) ->
          methodCalled = a and b and c
      }
    }, {})
    resource.methodName(true, true, true)
    expect(methodCalled).to.be.ok

  specify "has method returns true", ->
    resource = new DiscoveryResource("name", {
      methodName: {
        callMethod: ->

      }
    }, {})
    expect(resource.hasMethod("methodName")).to.be.ok

  specify "has method returns true", ->
    resource = new DiscoveryResource("name", {
      methodName: {
        callMethod: ->

      }
    }, {})
    expect(resource.getMethod("methodName")).to.exist