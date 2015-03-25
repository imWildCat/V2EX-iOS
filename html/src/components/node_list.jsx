import React from 'react';
import NodeCategory from './node_category';

class NodeList extends React.Component {

    constructor(props) {
        super(props);
        this.state = {data: props.initialData};
    }


    render() {
        console.log(this.state);
        var list = this.state.data.map(function(e) {
            return (
                <NodeCategory name={e.category} children={e.children} />
            )
        });

        return (
            <div className="node-list">{list}</div>
        );
    }
}

export default NodeList;