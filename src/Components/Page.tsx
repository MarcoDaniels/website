import * as React from 'react'

import AddressBar from './Bars/Address'
import StatusBar from './Bars/Status'
import Panel from './Panel'

export const Page: React.SFC = () => {

    return (
        <div>
            <AddressBar/>
            <Panel/>
            <StatusBar/>
        </div>
    )
}

export default Page