L.TimeSlider = L.Control.extend({
  options: {
    position: "bottomleft",
    timeLabels: null,
    interval: 1000,
    onTimeIdChange: function(timeId) {console.log(timeId)}
  },

  initialize: function(options) {
    L.Control.prototype.initialize.call(this, options);

    var container = L.DomUtil.create('div', "leaflet-bar leaflet-control leaflet-control-custom");
    container.style.padding = "5px";
    container.style.backgroundColor = 'white';

    var slider = L.DomUtil.create("input", "", container);
    slider.type = "range";
    slider.min = 0;
    slider.max = options.timeLabels.length - 1;
    slider.value = 0;

    var btn = L.DomUtil.create("button", "", container);
    btn.innerHTML = "play";

    this._container = container;
    this._slider = slider;
    this._play = false;
    this._btn = btn;
  },

  onAdd: function(map) {
    var self = this;
    self._slider.onchange = function(e) {self.options.onTimeIdChange(self._slider.value)};
    self._btn.onclick = function(e) {self.playPause()};


    L.DomEvent.on(self._slider, 'mousedown mouseup click', L.DomEvent.stopPropagation);
    L.DomEvent.on(self._slider, 'mouseenter', function(e) {
        map.dragging.disable();
    });
    L.DomEvent.on(self._slider, 'mouseleave', function(e) {
        map.dragging.enable();
    });

    return self._container;
  },

  playPause: function() {
    console.log("playpause");
    var self = this;
    self._play = !self._play;
    if(self._play) {
      if (self._slider.value == self._slider.max) {
        self._slider.value = 0;
        self.options.onTimeIdChange(self._slider.value);
      }

      self._intervalId = setInterval(function() {
        self._slider.value ++;
        self.options.onTimeIdChange(self._slider.value);
        if (self._slider.value == self._slider.max) {
          clearInterval(self._intervalId);
          self._play = false;
        }
      }, self.options.interval);
    } else {
      clearInterval(self._intervalId);
    }
  },
});

L.timeSlider = function(options) {
  return new L.TimeSlider(options);
};
