import * as React from 'react'
import NavigationPanel from './Navigation'
import CurrentPanel from './Current'
import PreviewPanel from './Preview'

export const Panel: React.SFC = () => {
    return (
        <div className="row">
            <div className="two columns">
                <NavigationPanel/>
            </div>
            <div className="eight columns">
                <CurrentPanel/>
            </div>
            <div className="two columns">
                <PreviewPanel/>
            </div>
        </div>
    )
}

export default Panel