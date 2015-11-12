import React from 'react';

class FavoriteCount extends React.Component {

  render() {

    var count = this.props.count;
    var style = {};
    if (parseInt(count) < 1) {
      style = {display: 'none'};
    }

    return (
      <div className="count fav-count" style={style}>
        <img className="icon" src="favorite_icon.png"/>
        <span className="count-number">{this.props.count}</span>
      </div>
    );
  }
}

export default FavoriteCount;