const {Elm} = require('./OriginRequest')
const app = Elm.OriginRequest.init()

exports.handler = (event, context, callback) => {
    app.ports.incomingEvent.send(event)
    app.ports.outgoingResult.subscribe((response) =>
        callback(null, response)
    )
}