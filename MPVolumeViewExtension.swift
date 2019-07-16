import MediaPlayer
extension MPVolumeView {
    var volumeSlider: UISlider? {
        for subview in subviews {
            if let v = subview as? UISlider {
                return v
            }
        }
        return nil
    }
}
