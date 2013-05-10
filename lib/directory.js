var fs = require('fs')
  , directory = {};

directory.mkdir_parent = function mkdir_parent (dir, mode) {
  try {
    fs.mkdirSync(dir, mode);
  } catch (error) {
    if (error && error.errno === 34) {
      mkdir_parent(path.dirname(dir), mode);
      mkdir_parent(dir, mode);
    }
  }
};

/**
 * Traverse directory(could be a file), 
 * given every traversed filename in handler.
 *
 * @param {string} dir Traversed directory name.
 * @param {function(string)} handler Self-defined handler.
 */
directory.traverse = function traverse (dir, handler) {
  handler(dir);
  if (fs.statSync(dir).isDirectory()) {
    fs.readdirSync(dir).forEach(function (subdir) {
      traverse(dir+'/'+subdir, handler);
    });
  }
};

module.exports = directory;
