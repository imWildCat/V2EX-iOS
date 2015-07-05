// index.jsx

import React from 'react';
import Topic from './components/topic/topic.jsx';
import StringExtension from './utils/string_extension.jsx';

var injectTapEventPlugin = require("react-tap-event-plugin");
injectTapEventPlugin();

React.render(
  <Topic topic={data} />
  ,
  document.body
);

