module.exports = {
  devServer: {
    historyApiFallback: {
      rewrites: [
        { from: '/home', to: '/index.html' },
        { from: '/work', to: '/index.html' },
        { from: '/skill', to: '/index.html' },
        { from: '/link', to: '/index.html' },
        { from: '/privacy', to: '/index.html' },
        { from: '/credit', to: '/index.html' },
      ],
    }
  },
};
