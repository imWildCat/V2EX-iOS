import React from 'react';
import AppreciationCount from './appreciation_count.jsx'
import FavoriteCount from './favorite_count.jsx'

class Post extends React.Component {
  render() {

    var post = this.props.data;

    var style = {};
    if (post.username == "") {
      style = {display: 'none'};
    }

    return (
      <div className="post" style={style}>
        <div className="meta">
          <div className="avatar">
            <img src={post.avatar_url}/>
          </div>
          <div className="info">
            <div className="row-1">
              {post.username}
            </div>
            <div className="row-2">
              <div className="left">
                <span className="time">{post.time}</span>
              </div>
              <div className="counts">

                <FavoriteCount count={post.favorite_count} />
                <AppreciationCount count={post.appreciation_count} />

              </div>
            </div>

          </div>
        </div>
        <div className="content" dangerouslySetInnerHTML={{__html: post.content}}>
        </div>
      </div>
    );
  }
}

export default Post;