import React from 'react';
import AppreciationCount from './appreciation_count.jsx';
import FavoriteCount from './favorite_count.jsx';
import NetWorking from '../../utils/networking.jsx';
import LazySizes from 'react-lazysizes';
//import PostActions from './post_actions';
import Tappable from 'react-tappable';
import AppreciatedPostStore from '../../store/appreciated_post.js';
import Reflux from 'reflux';
import $ from 'jquery';

var Post = React.createClass({

    mixins: [
        Reflux.listenTo(AppreciatedPostStore, 'onStoreUpdate')
    ],

    getInitialState: function () {

        var ia = this.props.data.is_appreciated == 'true';

        return {isAppreciated: ia}
    },


    onStoreUpdate: function (postIDList) {

        var id = this.props.data.id;
        var ia = false;
        for (var i = 0; i < postIDList.length; i++) {
            if (parseInt(postIDList[i]) == id) {
                ia = true;
                this.props.data.appreciation_count++;
                break;
            }
        }

        if (ia) {
            this.setState(
                {isAppreciated: ia}
            );
        }
    },

    render: function () {
        var post = this.props.data;

        var style = {};
        if (post.username == "") {
            style = {display: 'none'};
        }

        var row1ClassName = 'row-1';
        if(navigator.userAgent.indexOf('iPhone OS 9_0') > -1) {
            row1ClassName += ' ios-9';
        }

        return (
            <div className="post" style={style}>
                <Tappable onPress={() => this.onPostPress(post.id)}>
                    <div className="meta">
                        <div className="avatar" onTouchTap={() => this.onUserClick(post.username)}>
                            <LazySizes dataSrc={post.avatar_url} src="avatar_placeholder.png"/>
                        </div>
                        <div className="info">
                            <div className={row1ClassName}>
                                <span onTouchTap={() => this.onUserClick(post.username)}>{post.username}</span>
                            </div>
                            <div className="row-2">
                                <div className="left">
                                    <span className="time">{post.time}</span>
                                </div>
                                <div className="counts">
                                    <FavoriteCount count={post.favorite_count}/>
                                    <AppreciationCount count={post.appreciation_count}
                                                       isAppreciated={this.state.isAppreciated}/>
                                </div>

                            </div>
                        </div>
                    </div>
                    <div className="content" ref="content" dangerouslySetInnerHTML={{__html: post.content}}>
                    </div>
                </Tappable>
            </div>
        );
    },

    onUserClick: function (username) {
        console.log(username);
        NetWorking.loadURL('webview://show_member?username=' + username);
    },

    onPostPress: function (postID) {
        NetWorking.loadURL('webview://show_post_actions?postID=' + postID);
    },

    componentDidMount: function () {
        var contentJQ = $(this.refs.content.getDOMNode());
        contentJQ.find('a').each(function () {
            var url = $(this).attr('href');

            // handle @user
            if (url.startsWith('/member/')) {
                var username = url.match(/\/member\/(\w+)/)[1];
                if (username != null) {
                    $(this).attr('href', 'webview://show_member?username=' + username);
                    return;
                }
            }

            // handle /go/node
            if (url.startsWith('/go/')) {
                var nodeSlug = url.match(/\/go\/(\w+)/)[1];
                if (nodeSlug != null) {
                    $(this).attr('href', 'webview://open_node?slug=' + nodeSlug);
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
                if (topicID != null) {
                    $(this).attr('href', 'webview://show_topic?id=' + topicID);
                    return;
                }
            }

            // handle open other sites
            if (url.startsWith('http://') || url.startsWith('https://')) {
                $(this).attr('href', 'webview://open_browser?url=' + url);
            }

        });

        // Handle images
        contentJQ.find('img').each(function () {
            var imageURL = $(this).attr('src');
            $(this).click(function () {
                NetWorking.loadURL('webview://show_image?url=' + imageURL);
            });
        });

        contentJQ.find('a > img').each(function () {
            $(this).parent().removeAttr("href");
        });

    }
});

export default Post;