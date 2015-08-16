import React from 'react';

class AppreciationCount extends React.Component {

    render() {

        var ia = this.props.isAppreciated || false;
        var count = this.props.count;
        var style = {};
        if (parseInt(count) < 1) {
            style = {display: 'none'};
        }

        var icon;
        if (ia) {
            icon = 'has_been_appreciated_icon.png';
        } else {
            icon = 'appreciation_icon.png'
        }

        return (
            <div className="count appr-count" style={style}>
                <img className="icon" src={icon} />
                <span>{this.props.count}</span>
            </div>
        );
    }
}

export default AppreciationCount;