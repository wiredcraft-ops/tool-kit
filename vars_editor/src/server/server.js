// content of index.js
const http = require('http')
const fs = require('fs')
const yaml = require('js-yaml')

const port = 3000



const requestHandler = (request, response) => {
  console.log(request.url)

  let result = {}

  try {
    result = yaml.safeLoad(fs.readFileSync('vars.yml', 'utf8'))
  } catch (e) {
    result = e
  }
  response.setHeader('Content-Type', 'application/json')
  response.end(JSON.stringify(result))
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${port}`)
})
