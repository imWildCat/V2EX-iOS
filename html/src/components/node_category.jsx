import React from 'react';
import Node from './node'

class NodeCategory extends React.Component {

    render() {
        var list = this.props.children.map(function (e) {
            return (
                <Node name={e.name} slug={e.slug} />
            )
        });

        return (
            <div className="node-category">
                <div className="category-name">
                    {this.props.name}
                </div>
                <div className="list">
                    {list}
                </div>
            </div>
        );
    }
}

export default NodeCategory;