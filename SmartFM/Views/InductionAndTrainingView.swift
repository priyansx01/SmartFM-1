import SwiftUI
import AVKit

// MARK: - Video Model
struct TrainingVideo: Identifiable {
    let id = UUID()
    let title: String
    let urlString: String
}

struct InductionAndTrainingView: View {
    // State for the video player popup
    @State private var activeVideo: TrainingVideo?
    
    // Accordion expand/collapse states
    @State private var isSmartBoxExpanded: Bool = false
    @State private var isPestControlExpanded: Bool = false
    
    // Data from your Android file
    let corporatePDFUrl = "https://smartfm.ismartfacitechpl.com/modules/corporate.pdf" // Adjust domain if needed
    
    let smartBoxVideos = [
        TrainingVideo(title: "Video 1", urlString: "https://smartfm.ismartfacitechpl.com/api/stream/c1/master.m3u8"),
        TrainingVideo(title: "Video 2", urlString: "https://smartfm.ismartfacitechpl.com/api/stream/c2/master.m3u8"),
        TrainingVideo(title: "Video 3", urlString: "https://smartfm.ismartfacitechpl.com/api/stream/c3/master.m3u8"),
        TrainingVideo(title: "Video 4", urlString: "https://smartfm.ismartfacitechpl.com/api/stream/c4/master.m3u8")
    ]
    
    let pestVideo = TrainingVideo(title: "Pest Control Training", urlString: "https://smartfm.ismartfacitechpl.com/api/stream/pest/master.m3u8")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // 1. Corporate Profile PDF Button
                Button(action: {
                    if let url = URL(string: corporatePDFUrl) {
                        UIApplication.shared.open(url) // Opens native iOS PDF Viewer/Safari
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        Text("Corporate Profile")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // 2. Smart Box Training Accordion
                DisclosureGroup(
                    isExpanded: $isSmartBoxExpanded,
                    content: {
                        VStack(spacing: 0) {
                            Divider().padding(.vertical, 10)
                            ForEach(smartBoxVideos) { video in
                                VideoRowItem(video: video) {
                                    activeVideo = video
                                }
                            }
                        }
                    },
                    label: {
                        HStack {
                            Image(systemName: "play.tv.fill")
                                .foregroundColor(.blue)
                            Text("Smart Box Training")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                )
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // 3. Pest Control Accordion
                DisclosureGroup(
                    isExpanded: $isPestControlExpanded,
                    content: {
                        VStack(spacing: 0) {
                            Divider().padding(.vertical, 10)
                            VideoRowItem(video: pestVideo) {
                                activeVideo = pestVideo
                            }
                        }
                    },
                    label: {
                        HStack {
                            Image(systemName: "ant.fill")
                                .foregroundColor(.green)
                            Text("Pest Control")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                )
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitle("Induction & Training", displayMode: .inline)
        // Native Fullscreen Video Player Popup
        .fullScreenCover(item: $activeVideo) { video in
            NativeVideoPlayerView(video: video)
        }
    }
}

// MARK: - Reusable Row Component
struct VideoRowItem: View {
    let video: TrainingVideo
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "play.circle")
                    .foregroundColor(.blue)
                Text(video.title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Native AVPlayer View Wrapper
struct NativeVideoPlayerView: View {
    let video: TrainingVideo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let url = URL(string: video.urlString) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .onAppear {
                            // Optionally autoplay when view appears
                            // AVPlayer(url: url).play()
                        }
                } else {
                    Text("Invalid Video URL")
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitle(video.title, displayMode: .inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        // Force player into dark mode for better cinematic feel
        .preferredColorScheme(.dark)
    }
}

struct InductionAndTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InductionAndTrainingView()
        }
    }
}
