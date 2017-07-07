(function() {
  'use strict';

  L.TimeSlider = L.Control.extend({
    options: {
      position: "bottomright",
      timeLabels: null,
      interval: 1000,
      onTimeIdChange: function(timeId) {console.log(timeId)}
    },

    initialize: function(options) {
      L.Control.prototype.initialize.call(this, options);

      var container = L.DomUtil.create('div', "leaflet-bar leaflet-control");
      container.style.padding = "5px";
      container.style.backgroundColor = 'white';

      var label = L.DomUtil.create("p", "time-slider-label", container);
      var sliderContainer = L.DomUtil.create("div", "leaflet-control-slider", container);

      var slider = L.DomUtil.create("input", "time-slider", sliderContainer);
      slider.type = "range";
      slider.min = 0;
      slider.max = options.timeLabels.length - 1;
      slider.value = 0;

      var btn = L.DomUtil.create("i", "playpause fa fa-play", sliderContainer);

      this._container = container;
      this._slider = slider;
      this._play = false;
      this._btn = btn;
      this._label = label;
    },

    onAdd: function(map) {
      var self = this;
      self.map = map;

      L.DomEvent.disableClickPropagation(self._container);
      self._slider.onchange = function(e) {
        self.setTimeId(self.getTimeId(), true);
        self.updateGroup(function(map) {
          map.controls._controlsById.tslider.setTimeId(self.getTimeId());
        });
      };
      self._btn.onclick = function(e) {
        self.playPause(!self._play);
        self.updateGroup(function(map) {
          map.controls._controlsById.tslider.playPause(self._play);
        });
      };

      self.setTimeLabels(self.options.timeLabels);

      return self._container;
    },

    playPause: function(play) {
      var self = this;
      self._play = play;
      if(self._play) {
        self._btn.className = "playpause fa fa-pause";
        if (self.getTimeId() == self._slider.max) {
          self.setTimeId(0);
        }

        self._intervalId = setInterval(function() {
          self.setTimeId(self.getTimeId() + 1);
          if (self.getTimeId() == self._slider.max) {
            clearInterval(self._intervalId);
            self._play = false;
            self._btn.className = "playpause fa fa-play";
          }
        }, self.options.interval);
      } else {
        clearInterval(self._intervalId);
        self._btn.className = "playpause fa fa-play";
      }
    },

    setTimeId: function(timeId, skip) {
      var self = this;
      if (!skip) self._slider.value = timeId;
      self._label.innerHTML = self.options.timeLabels[timeId];
      self.options.onTimeIdChange(timeId);
    },

    getTimeId: function() {
      return parseInt(this._slider.value);
    },

    setTimeLabels: function(timeLabels) {
      if (timeLabels === null) return;
      var self = this;

      if (typeof timeLabels == "undefined") {
        timeLabels = ["undefined"];
      } else if (timeLabels.constructor != Array) {
        timeLabels = [timeLabels];
      }

      if (timeLabels.length < 2) {
        self._container.style.display = "none";
      } else {
        self._container.style.display = "block";
      }

      var currentTimeLabel = self.options.timeLabels[self.getTimeId()];
      self.options.timeLabels = timeLabels;
      var newTimeId = self.toTimeId(currentTimeLabel);

      self._slider.max = timeLabels.length - 1;
      self.setTimeId(newTimeId);
    },

    toTimeId: function(label) {
      if (typeof this.options.timeLabels == "undefined" ||
            this.options.timeLabels.constructor != Array) {
        return 0;
      }

      var timeId = this.options.timeLabels.indexOf(label);
      if (timeId == -1) timeId = 0;
      return timeId;
    },

    updateGroup: function(updateFun) {
      var self = this;
      if (self.map.syncGroup) {
        var syncMap;
        for (var i = 0; i < LeafletWidget.syncGroups[self.map.syncGroup].length; i++) {
          syncMap = LeafletWidget.syncGroups[self.map.syncGroup][i];
          if (syncMap != self.map && syncMap.controls._controlsById.tslider) {
            updateFun(syncMap);
          }
        }
      }
    }
  });

  L.timeSlider = function(options) {
    return new L.TimeSlider(options);
  };
}());
