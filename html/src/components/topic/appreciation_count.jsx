import React from 'react';

class AppreciationCount extends React.Component {

  render() {

    var count = this.props.count;
    var style = {};
    if (parseInt(count) < 1) {
      style = {display: 'none'};
    }

    return (
      <div className="count appr-count" style={style}>
        <img className="icon" src="appreciation_icon.png"/>
        <span>{this.props.count}</span>
      </div>
    );
  }
}

export default AppreciationCount;