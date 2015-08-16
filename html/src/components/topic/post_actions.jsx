import React from 'react';

class PostActions extends React.Component {

    render() {

        var id = this.props.postID;
        var style = {
            backgroundColor: '#5187F4',
            width: 80,
            //float: 'right',
            height: 40
        };

        var buttonStyle = {
            display: 'inline-block',
            width: 40,
            height: 40
        };

        return (
            <div className="actions" style={style}>
                <span style={buttonStyle}>@</span>
                <span style={buttonStyle}></span>
            </div>
        );
    }
}

export default PostActions;