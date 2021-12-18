plot(0, xlim=c(0, 320), ylim=c(0, 15000), ylab="Height", xlab="Time (steps)", main="Probe height over time (steps)")
for (track_file in dir("tracks", full.names = TRUE)) {
  track = read.csv(track_file, header=TRUE, sep=",")
  lines(track$y)
}

