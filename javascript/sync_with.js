(function() {
  'use strict';

  LeafletWidget.methods.syncWith = function(groupname) {
    var self = this;
    if (!LeafletWidget.syncGroups) {
      LeafletWidget.syncGroups = {};
      LeafletWidget.syncGroups.sync = function(map, groupname) {
        var zoom = map.getZoom();
        var center = map.getCenter();
        for (var i = 0; i < LeafletWidget.syncGroups[groupname].length; i++) {
          LeafletWidget.syncGroups[groupname][i].setView(center, zoom, {animate: false});
        }
      }
    }
    if (!LeafletWidget.syncGroups[groupname]) LeafletWidget.syncGroups[groupname] = [];

    LeafletWidget.syncGroups[groupname].push(self);

    self.on("move", function() {
      LeafletWidget.syncGroups.sync(self, groupname);
    });

    self.syncGroup = groupname;
    LeafletWidget.syncGroups.sync(self, groupname);
  }
}());
