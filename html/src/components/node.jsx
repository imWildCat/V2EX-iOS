import React from 'react';
import Networking from '../utils/networking'

class Node extends React.Component {

    onNodeClick() {
        console.log(Networking);
        Networking.loadURL('webview://open_node?slug=' + this.props.slug)
    }

    render() {
        return (
            <div className="node">
                <a href="#" onClick={this.onNodeClick.bind(this)}>{this.props.name}</a>
            </div>
        );
    }
}

export default Node;