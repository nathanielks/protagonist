{assert} = require 'chai'
protagonist = require '../build/Release/protagonist'

describe "API Blueprint parser", ->
  it 'parses API name', ->
    protagonist.parse '# My API', (err, result) ->

      assert.isNull err
      assert.isDefined result
      assert.strictEqual result.ast.name, 'My API'

  it 'parses API description', ->
    source = """
**description**

"""
    protagonist.parse source, (err, result) ->
      
      assert.isNull err

      assert.isDefined result
      assert.strictEqual result.ast.name, ''
      assert.isDefined result.ast.description
      assert.strictEqual result.ast.description, '**description**\n'

  it 'parses resource group', ->
    source = """
---

# Group Name
_description_

"""
    protagonist.parse source, (err, result) ->

      assert.isNull err

      assert.isDefined result.ast.resourceGroups
      assert.strictEqual result.ast.resourceGroups.length, 1
      assert.isDefined result.ast.resourceGroups[0] 

      resourceGroup = result.ast.resourceGroups[0]
      assert.isDefined resourceGroup.name
      assert.strictEqual resourceGroup.name, 'Group Name'
      assert.isDefined resourceGroup.description
      assert.strictEqual resourceGroup.description, '_description_\n'

  it 'parses resource', ->
    source = """
# /resource
Resource description

+ Headers

        X-Resource-Header: Metaverse

## GET
Method description

+ Headers

        X-Method-Header: Pizza delivery

+ Response 200 (text/plain)
  
  Response description

  + Headers

            X-Response-Header: Fighter

  + Body

            Y.T.

  + Schema

            Kourier
"""
    protagonist.parse source, (err, result) ->
      assert.isNull err

      assert.strictEqual result.ast.resourceGroups.length, 1

      resourceGroup = result.ast.resourceGroups[0]
      assert.strictEqual resourceGroup.name, ''
      assert.strictEqual resourceGroup.description, ''
      
      assert.isDefined resourceGroup.resources
      assert.strictEqual resourceGroup.resources.length, 1
      assert.isDefined resourceGroup.resources[0]

      resource = resourceGroup.resources[0]
      assert.isDefined resource.uri
      assert.strictEqual resource.uri, '/resource'
      assert.isDefined resource.description
      assert.strictEqual resource.description, 'Resource description\n\n'
      assert.isDefined resource.headers
      assert.strictEqual resource.headers.length, 1
      assert.isDefined resource.headers[0].name
      assert.strictEqual resource.headers[0].name, 'X-Resource-Header'
      assert.isDefined resource.headers[0].value
      assert.strictEqual resource.headers[0].value, 'Metaverse'

      assert.isDefined resource.methods
      assert.strictEqual resource.methods.length, 1
      assert.isDefined resource.methods[0]

      method = resource.methods[0]
      assert.isDefined method.method
      assert.strictEqual method.method, 'GET'
      assert.isDefined method.description
      assert.strictEqual method.description, 'Method description\n\n'
      assert.isDefined method.headers
      assert.strictEqual method.headers.length, 1
      assert.isDefined method.headers[0].name
      assert.strictEqual method.headers[0].name, 'X-Method-Header'
      assert.isDefined method.headers[0].value
      assert.strictEqual method.headers[0].value, 'Pizza delivery'

      assert.isDefined method.requests
      assert.strictEqual method.requests.length, 0
      assert.isDefined method.responses
      assert.strictEqual method.responses.length, 1
      assert.isDefined method.responses[0]

      response = method.responses[0]
      assert.isDefined response.name
      assert.strictEqual response.name, '200'
      assert.isDefined response.description
      assert.strictEqual response.description, 'Response description\n'

      assert.isDefined response.headers
      assert.strictEqual response.headers.length, 2
      assert.isDefined response.headers[0].name
      assert.strictEqual response.headers[0].name, 'Content-Type'
      assert.isDefined response.headers[0].value
      assert.strictEqual response.headers[0].value, 'text/plain'
      assert.isDefined response.headers[1].name
      assert.strictEqual response.headers[1].name, 'X-Response-Header'
      assert.isDefined response.headers[1].value
      assert.strictEqual response.headers[1].value, 'Fighter'

      assert.isDefined response.body
      assert.strictEqual response.body, 'Y.T.\n'
      assert.isDefined response.schema
      assert.strictEqual response.schema, 'Kourier\n'

  it 'fails to parse blueprint with tabs', ->
    source = """
# /resource
# GET
+ Response 
\tC
"""
    protagonist.parse source, (err, result) ->

      assert.isDefined err
      assert.isNotNull err
      assert err.message.length != 0
      assert err.code != 0
      assert.isDefined err.location

  it 'parses blueprint with warnings', ->
    source = """
API description

---

Group description

"""
    protagonist.parse source, (err, result) ->

      assert.isNull err

      assert.isDefined result.warnings
      assert result.warnings.length, 2
      
      assert.isDefined result.warnings[0].message
      assert.isDefined result.warnings[0].code
      assert.isDefined result.warnings[0].location

      assert.isDefined result.warnings[1].message
      assert.isDefined result.warnings[1].code
      assert.isDefined result.warnings[1].location

      assert.isDefined result.ast

