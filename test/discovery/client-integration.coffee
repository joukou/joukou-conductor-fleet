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

clientModule      = require( '../../dist/discovery/client')
chai              = require( 'chai' )
chaiAsPromised    = require( 'chai-as-promised' )
chai.use(chaiAsPromised)
expect            = chai.expect
restify           = require('restify')
request           = require('request')

discovery =
  schemas:
    UnitPage:
      type: "object"
      properties:
        units:
          type: "array"
          items:
            $ref: "Unit"
        nextPageToken:
          type: 'string'
    Unit:
      type: "object"
      properties:
        name:
          type:"string"
          required:true
    NextPageTest:
      type: "object"
      properties:
        nextPageToken:
          type: "string"
        values:
          type: "array"
  resources:
    resource:
      methods:
        get:
          id: "get"
          description: "get"
          httpMethod: "GET"
          path: "resource"
          parameters:
            name:
              type: "string"
              location: "query"
        nextPageTest:
          id: "nextPageTest"
          description: "test for next page token"
          httpMethod: "GET"
          path: "nextPage"
          parameters:
            nextPageToken:
              type: "string"
              location: "query"
          response:
            $ref: "NextPageTest"
        nextPageTestNoSecond:
          id: "nextPageTestNoSecond"
          description: "test for next page token"
          httpMethod: "GET"
          path: "nextPageTestNoSecond"
          parameters:
            nextPageToken:
              type: "string"
              location: "query"
          response:
            $ref: "NextPageTest"


basePath = "/v1-alpha/"
port = 8080

startServer = (callback) ->
  server = restify.createServer()
  server.get("#{basePath}discovery.json", (res, req, next) ->
    req.send(discovery)
    next()
  )
  server.get("#{basePath}resource", (req, res, next) ->
    res.send(resource: true)
    next()
  )
  server.get("#{basePath}nextPage", (req, res, next) ->
    nextPageToken = "test"
    if req.url.indexOf("nextPageToken") > -1
      nextPageToken = null
    res.send({values:[{value:"test"}], nextPageToken: nextPageToken})
    next()
  )
  server.get("#{basePath}nextPageTestNoSecond", (req, res, next) ->
    res.send({values:[{value:"test"}]})
    next()
  )
  server.listen(port, ->
    callback(server)
  )

asyncServer = (callback, done) ->
  startServer((server) ->
    callback(->
      callbackArguments = arguments
      server.close(->
        args = []
        if typeof callbackArguments[0] is "string"
          args.push(new Error(callbackArguments[0]))
        else if callbackArguments[0] instanceof Error
          args.push(callbackArguments[0])
        done.apply(done, args)
      )
    , server)
  )

describe "client integration tests", ->
  specify "request succeeds", (done) ->
    asyncServer((actuallyDone, server)->
      request.get("#{server.url}#{basePath}discovery.json", (err, res, body) ->
        expect(err).to.not.exist
        expect(res.statusCode).to.equal(200)
        expect(body).to.equal(JSON.stringify(discovery))
        actuallyDone()
      )
    , done)

  specify "discovery json is resolved", (done) ->
    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      expect(client.onDiscovery()).to.eventually.equal(client).notify(actuallyDone)

    , done)
  specify "resources are resolved", (done) ->
    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      client.onDiscovery().then(->
        expect(client).to.include.key("resource")
      ).then(actuallyDone)

    , done)

  specify "methods are resolved", (done) ->
    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      client.onDiscovery().then(->
        expect(client.resource).to.include.key("get")
        expect(client.resource.get).to.be.instanceof(Function)
      ).then(actuallyDone)

    , done)


  specify "methods are called", (done) ->
    this.timeout(3000)

    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      client.onDiscovery().then(->
        promise = client.resource.get()
        expect(promise).to.eventually.include.key("resource").notify(actuallyDone)
      )
    , done)

  specify "method follows next page token", (done) ->
    this.timeout(3000)

    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      client.onDiscovery().then(->
        promise = client.resource.nextPageTest()
        promise.then((a)->
          if a.length isnt 2
            actuallyDone(new Error("response.length is expected to be 2"))
            return
          actuallyDone()
        ).fail(actuallyDone)
      )
    , done)

  specify "method doesn't follow next page token, but returns array", (done) ->
    this.timeout(3000)

    asyncServer((actuallyDone, server)->

      client = clientModule.getClient(server.url, basePath, true)
      client.onDiscovery().then(->
        promise = client.resource.nextPageTestNoSecond()
        promise.then((a)->
          if a.length isnt 1
            actuallyDone(new Error("response.length is expected to be 1"))
            return
          actuallyDone()
        ).fail(actuallyDone)
        # expect(promise).to.eventually.have.lengthOf(1).notify(actuallyDone)
      )
    , done)

