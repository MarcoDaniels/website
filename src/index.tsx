import * as React from 'react'
import { render } from 'react-dom'
import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { ApolloProvider } from 'react-apollo'
import { InMemoryCache } from 'apollo-cache-inmemory'
import App from './app'

const httpLink = createHttpLink({
    uri: process.env.REACT_APP_GRAPH_QL_API,
})

const client = new ApolloClient({
    link: httpLink,
    cache: new InMemoryCache()
})

const WrappedApp = (
    <ApolloProvider client={client}>
        <App/>
    </ApolloProvider>
)

render(WrappedApp, document.getElementById('root'))
