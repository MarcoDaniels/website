const {Elm} = require('./originRequestElm')
const app = Elm.OriginRequest.init()

exports.handler = (event, context, callback) => {
    app.ports.inputEvent.send(event)
    app.ports.outputEvent.subscribe((output) =>
        callback(null, output)
    )
}