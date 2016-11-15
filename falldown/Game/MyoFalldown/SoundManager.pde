import ddf.minim.Minim;
import ddf.minim.Controller;
import ddf.minim.AudioPlayer;


/* This class provides an abstract wrapper around any 3rd party sound libraries,
 * so that the rest of our code base doesn't directly interface the 3rd party
 * API. This means Momo code won't have to change when: a) the 3rd party
 * updates their API, b) we decide to switch to another library.
*/
class SoundManager {
  Minim m;

  public SoundManager(PApplet mainObject) {
    m = new Minim(mainObject);
  }

  public SoundObject loadSoundFile(String filename) {
    return new SoundObject(m.loadFile(filename));
  }
}


class SoundObject {
  AudioPlayer audioPlayer;

  public SoundObject(AudioPlayer p) {
    audioPlayer = p;
  }

  public void play() {
    audioPlayer.rewind();
    audioPlayer.play();
  }

  public void stop() {
    audioPlayer.pause();
    audioPlayer.rewind();
  }

  public void loop() {
    audioPlayer.rewind();
    audioPlayer.loop();
  }

  public void setVolume(float level) {
    if (audioPlayer.hasControl(Controller.VOLUME)) {
      // this is the most straightforward approach, simply specify a level in range [0, 1].
      // However, this library function doesn't seem to be supported.
      audioPlayer.setVolume(level);

    } else if (audioPlayer.hasControl(Controller.GAIN)) {
      // specify a level in decibels. A safe range seems to be [-40, 40], so scale level
      // appropriately. Since the quietest level is still slightly audible, explicitly mute
      // when level is 0.
      audioPlayer.setGain((level*80)-40);
      if (level == 0)
        audioPlayer.mute();
      else
        audioPlayer.unmute();
    }
  }

  public void setPan(float level) {
    if (audioPlayer.hasControl(Controller.PAN))
      audioPlayer.setPan(level);
  }
}
