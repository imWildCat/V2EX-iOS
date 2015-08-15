import React from 'react';
import AppreciationCount from './appreciation_count.jsx'
import FavoriteCount from './favorite_count.jsx'
import NetWorking from '../../utils/networking.jsx'
import $ from 'jquery'; 

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
          <div className="avatar" onTouchTap={() => this.onUserClick(post.username)} >
            <img src={post.avatar_url} />
          </div>
          <div className="info">
            <div className="row-1">
              <span onTouchTap={() => this.onUserClick(post.username)}>{post.username}</span>
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
        <div className="content" ref="content" dangerouslySetInnerHTML={{__html: post.content}}>
        </div>
      </div>
    );
  }

  onUserClick(username) {
    console.log(username);
    NetWorking.loadURL('webview://show_member?username=' + username);
  }

  componentDidMount() {
    var contentJQ = $(this.refs.content.getDOMNode());
    contentJQ.find('a').each(function() {
      var url = $(this).attr('href');

      // handle @user
      if (url.startsWith('/member/')) {
        var username = url.match(/\/member\/(\w+)/)[1];
        if(username != null) {
          $(this).attr('href', 'webview://show_member?username=' + username);
          return;
        }
      }

      // handle /go/node
      if (url.startsWith('/go/')) {
        var nodeSlug = url.match(/\/go\/(\w+)/)[1];
        if(nodeSlug != null) {
          $(this).attr('href', 'webview://show_node?slug=' + nodeSlug);
          return;
        }
      }

      // handle /t/000
      if (url.startsWith('/t/') 
        || url.startsWith('https://v2ex.com/t/') 
        || url.startsWith('http://v2ex.com/t/')
        || url.startsWith('http://www.v2ex.com/t/')
        || url.startsWith('https://www.v2ex.com/t/')) {
        var topicID = url.match(/\/t\/(\w+)/)[1];
        if(topicID != null) {
          $(this).attr('href', 'webview://show_topic?id=' + topicID);
          return;
        }
      }

      // handle open other sites
      if (url.startsWith('http://') || url.startsWith('https://')) {
        $(this).attr('href', 'webview://open_browser?url=' + url);
        return;
      }

    });

    // Handle images
    contentJQ.find('img').each(function() {
      var imageURL = $(this).attr('src');
      $(this).click(function() {
        NetWorking.loadURL('webview://show_image?url=' + imageURL);
      });
    });

    contentJQ.find('a > img').each(function() {
      $(this).parent().removeAttr("href");
    });
   
  }
}

export default Post;