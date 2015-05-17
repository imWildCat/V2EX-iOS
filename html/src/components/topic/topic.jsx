import React from 'react';
import Post from './post.jsx'

class Topic extends React.Component {

  render() {

    var i = 0;
    var posts = this.props.topic.posts.map(function (p) {
      i++;
      return <Post data={p} key={'p_'+ i}/>
    });

    return (
      <div className="topic">
        <div className="title">
          {this.props.topic.title}
        </div>
        {posts}
      </div>
    );
  }
}

export default Topic;