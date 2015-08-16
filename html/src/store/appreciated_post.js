var Reflux = require('reflux');

var _postIDList = [];

var AppreciatedPostStore = Reflux.createStore({

    init: function() {
    },

    onUpdate: function(id) {
        _postIDList.push(id);
        this.trigger(_postIDList);
    }

});

window.addAppreciatedPost = function (postID) {
    AppreciatedPostStore.onUpdate(postID)
};

module.exports = AppreciatedPostStore;