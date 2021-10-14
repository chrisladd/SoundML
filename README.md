# SoundML

Using built-in machine learning to classify sounds.

A SoundML `Analyzer` object observes audio buffers, and maintains an internal ML analysis, reporting onUpdate for any `SoundGroup` of interest. A `SoundGroup` represents one or more `Sound` objects, any of which matching above their threshold consitutes a match. These `Sound` objects represent a specific ML recognition.

The `SoundType` enum represents all known labels of the `SNClassifierIdentifier.version1 model` as of iOS 15.0.

## Usage

### Setup

First, create an Analyzer object, and, optionally, adjust its properties:

```swift
import SoundML

let analyzer = Analyzer()
analyzer.windowDuration = 0.75

```

Next, set one or more `SoundGroup` instances you'd like to observe.

Let's imagine you're working on an app that keeps track of when you're snoring, and when you're talking in your sleep at night:

```Swift
analyzer.soundGroups = [
            SoundGroup(.speech, threshold: 0.7),
            SoundGroup(.snoring, threshold: 0.4)
        ]
```

You can also include more than one sound in each group, with different threshold. Imagine you wanted to count either speech or whispering:

```swift
analyzer.soundGroups = [
            SoundGroup(.snoring, threshold: 0.4),
            SoundGroup(id: "talking", sounds: [
                Sound(.speech, threshold: 0.7),
                Sound(.whispering, threshold: 0.5)
            ])
        ]
```

In this case, *either* speech *or* whispering, at confidence levels of 70% and 50%, respectively, would trigger the group with id `talking`. 

### Processing

As you receive audio buffers, from an AVAudioEngine, for example, pass them to the analyzer:

```swift
audioEngine.inputNode.installTap(onBus: 0, bufferSize: 2048, format: nil) { [weak self] buffer, time in
	self?.analyzer.process(buffer: buffer, time: time)
}

```

### Analysis

Asynchronously, as the internal `SNAudioStreamAnalyzer` builds up enough samples to process, the Analyzer will call its `onUpdate` handler.

This contains a Bool representing whether a match occurred, as well as an array of matches for any sounds that successfully matched:

```swift
analyzer.onUpdate = { [weak self] _, groups in
    guard let groups = groups else {
        print("No matches for this frame.")
        return
    }
    
    for match in groups {
        print("Matched: \(match.sound.label)\n\(Int(match.confidence * 100))%)
    }
}
```

These match objects contain the `SoundGroup` that matched the recently processed sound, the `Sound` within that group that matched most highly, and the `confidence` of the match. This value must be above that sound's `threshold`.

Note that multiple matches can occur at the same time. If, for example, two people were sleeping, with one talking, and the other snoring, as often happens.



## Known Sounds

Below is an alphabetized list of sounds the Analyzer can recognize. You may pass these as strings, or use the `SoundType` enum.

- `accordion`
- `acoustic_guitar`
- `air_conditioner`
- `air_horn`
- `aircraft`
- `airplane`
- `alarm_clock`
- `ambulance_siren`
- `applause`
- `artillery_fire`
- `babble`
- `baby_crying`
- `baby_laughter`
- `bagpipes`
- `banjo`
- `basketball_bounce`
- `bass_drum`
- `bass_guitar`
- `bassoon`
- `bathtub_filling_washing`
- `battle_cry`
- `bee_buzz`
- `beep`
- `bell`
- `belly_laugh`
- `bicycle`
- `bicycle_bell`
- `bird`
- `bird_chirp_tweet`
- `bird_flapping`
- `bird_squawk`
- `bird_vocalization`
- `biting`
- `blender`
- `boat_water_vehicle`
- `boiling`
- `booing`
- `boom`
- `bowed_string_instrument`
- `bowling_impact`
- `brass_instrument`
- `breathing`
- `burp`
- `bus`
- `camera`
- `car_horn`
- `car_passing_by`
- `cat`
- `cat_meow`
- `cat_purr`
- `cello`
- `chainsaw`
- `chatter`
- `cheering`
- `chewing`
- `chicken`
- `chicken_cluck`
- `children_shouting`
- `chime`
- `choir_singing`
- `chopping_food`
- `chopping_wood`
- `chuckle_chortle`
- `church_bell`
- `civil_defense_siren`
- `clapping`
- `clarinet`
- `click`
- `clock`
- `coin_dropping`
- `cough`
- `cow_moo`
- `cowbell`
- `coyote_howl`
- `cricket_chirp`
- `crow_caw`
- `crowd`
- `crumpling_crinkling`
- `crushing`
- `crying_sobbing`
- `cutlery_silverware`
- `cymbal`
- `didgeridoo`
- `disc_scratching`
- `dishes_pots_pans`
- `dog`
- `dog_bark`
- `dog_bow_wow`
- `dog_growl`
- `dog_howl`
- `dog_whimper`
- `door`
- `door_bell`
- `door_slam`
- `door_sliding`
- `double_bass`
- `drawer_open_close`
- `drill`
- `drum`
- `drum_kit`
- `duck_quack`
- `electric_guitar`
- `electric_piano`
- `electric_shaver`
- `electronic_organ`
- `elk_bugle`
- `emergency_vehicle`
- `engine`
- `engine_accelerating_revving`
- `engine_idling`
- `engine_knocking`
- `engine_starting`
- `eruption`
- `finger_snapping`
- `fire`
- `fire_crackle`
- `fire_engine_siren`
- `firecracker`
- `fireworks`
- `flute`
- `fly_buzz`
- `foghorn`
- `fowl`
- `french_horn`
- `frog`
- `frog_croak`
- `frying_food`
- `gargling`
- `gasp`
- `giggling`
- `glass_breaking`
- `glass_clink`
- `glockenspiel`
- `gong`
- `goose_honk`
- `guitar`
- `guitar_strum`
- `guitar_tapping`
- `gunshot_gunfire`
- `gurgling`
- `hair_dryer`
- `hammer`
- `hammond_organ`
- `harmonica`
- `harp`
- `harpsichord`
- `hedge_trimmer`
- `helicopter`
- `hi_hat`
- `hiccup`
- `horse_clip_clop`
- `horse_neigh`
- `humming`
- `insect`
- `keyboard_musical`
- `keys_jangling`
- `knock`
- `laughter`
- `lawn_mower`
- `lion_roar`
- `liquid_dripping`
- `liquid_filling_container`
- `liquid_pouring`
- `liquid_sloshing`
- `liquid_splashing`
- `liquid_spraying`
- `liquid_squishing`
- `liquid_trickle_dribble`
- `mallet_percussion`
- `mandolin`
- `marimba_xylophone`
- `mechanical_fan`
- `microwave_oven`
- `mosquito_buzz`
- `motorboat_speedboat`
- `motorcycle`
- `music`
- `nose_blowing`
- `oboe`
- `ocean`
- `orchestra`
- `organ`
- `owl_hoot`
- `percussion`
- `person_running`
- `person_shuffling`
- `person_walking`
- `piano`
- `pig_oink`
- `pigeon_dove_coo`
- `playing_badminton`
- `playing_hockey`
- `playing_squash`
- `playing_table_tennis`
- `playing_tennis`
- `playing_volleyball`
- `plucked_string_instrument`
- `police_siren`
- `power_tool`
- `power_windows`
- `printer`
- `race_car`
- `rail_transport`
- `railroad_car`
- `rain`
- `raindrop`
- `rapping`
- `ratchet_and_pawl`
- `rattle_instrument`
- `reverse_beeps`
- `ringtone`
- `rooster_crow`
- `rope_skipping`
- `rowboat_canoe_kayak`
- `sailing`
- `saw`
- `saxophone`
- `scissors`
- `screaming`
- `scuba_diving`
- `sea_waves`
- `sewing_machine`
- `sheep_bleat`
- `shofar`
- `shout`
- `sigh`
- `silence`
- `singing`
- `singing_bowl`
- `sink_filling_washing`
- `siren`
- `sitar`
- `skateboard`
- `skiing`
- `slap_smack`
- `slurp`
- `smoke_detector`
- `snake_hiss`
- `snake_rattle`
- `snare_drum`
- `sneeze`
- `snicker`
- `snoring`
- `speech`
- `squeak`
- `steel_guitar_slide_guitar`
- `steelpan`
- `stream_burbling`
- `subway_metro`
- `synthesizer`
- `tabla`
- `tambourine`
- `tap`
- `tearing`
- `telephone`
- `telephone_bell_ringing`
- `theremin`
- `thump_thud`
- `thunder`
- `thunderstorm`
- `tick`
- `tick_tock`
- `timpani`
- `toilet_flush`
- `toothbrush`
- `traffic_noise`
- `train`
- `train_horn`
- `train_wheels_squealing`
- `train_whistle`
- `trombone`
- `truck`
- `trumpet`
- `tuning_fork`
- `turkey_gobble`
- `typewriter`
- `typing`
- `typing_computer_keyboard`
- `ukulele`
- `underwater_bubbling`
- `vacuum_cleaner`
- `vehicle_skidding`
- `vibraphone`
- `violin_fiddle`
- `water`
- `water_pump`
- `water_tap_faucet`
- `waterfall`
- `whale_vocalization`
- `whispering`
- `whistling`
- `whoosh_swoosh_swish`
- `wind`
- `wind_chime`
- `wind_instrument`
- `wind_noise_microphone`
- `wind_rustling_leaves`
- `wood_cracking`
- `writing`
- `yell`
- `yodeling`
- `zipper`
- `zither`
