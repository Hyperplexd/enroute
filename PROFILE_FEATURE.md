# Profile Screen Feature Documentation

## Overview

The Profile screen provides users with a comprehensive view of their learning journey, tracking their podcast history, learning statistics, and preferences.

## Features

### 📊 Learning Statistics

**Four Key Metrics:**
1. **Completed Podcasts** - Total number of podcasts finished
2. **Minutes Learned** - Total time spent learning
3. **Current Streak** - Consecutive days of learning
4. **Best Streak** - Longest learning streak achieved

### 🎯 Favorite Topics

- Visual topic chips showing user preferences
- Topics: Technology, Science, History (customizable)
- Easy to add/remove topics
- Used for AI personalization

### 📚 Podcast History

**Tracked Information:**
- Podcast title and category
- Duration and date listened
- Completion status
- Progress percentage for in-progress podcasts
- Visual progress indicators

**History States:**
- ✅ **Completed** - Finished podcasts with checkmark
- ⏯️ **In Progress** - Partially completed with progress bar
- 📅 **Recent** - Smart date formatting (Today, Yesterday, X days ago)

### 👤 User Profile Header

- Large gradient avatar with user initial
- User name and email display
- Settings button for profile customization
- Beautiful gradient background

## Architecture

### ProfileProvider (`lib/providers/profile_provider.dart`)

**State Management:**
```dart
- userName: String
- userEmail: String
- podcastHistory: List<PodcastHistoryItem>
- totalPodcastsCompleted: int
- totalMinutesLearned: int
- currentStreak: int
- longestStreak: int
- favoriteTopics: List<String>
```

**Key Methods:**
- `addPodcastToHistory()` - Add new podcast to history
- `updatePodcastProgress()` - Update listening progress
- `getRecentPodcasts()` - Get last 7 days of podcasts
- `getCompletedPodcasts()` - Filter completed only
- `getInProgressPodcasts()` - Filter in-progress only

### PodcastHistoryItem Model

```dart
{
  podcast: Podcast,
  listenedAt: DateTime,
  completed: bool,
  progressPercentage: int (0-100)
}
```

## UI Components

### 1. Collapsible App Bar
- Expands to show full profile header
- Collapses while scrolling
- Smooth animations

### 2. Statistics Cards
- 2x2 grid layout
- Color-coded icons
- Large metric numbers
- Descriptive labels

### 3. Topic Chips
- Horizontal wrap layout
- Primary color accent
- Rounded corners
- Tap to manage

### 4. History List
- Scrollable list view
- Card-based design
- Icon indicators
- Progress bars for in-progress items

### 5. Bottom Navigation
- 3 tabs: Path, Library, Profile
- Active state highlighting
- Smooth navigation

## Integration Points

### Learning Path Screen
When a user starts a podcast:
```dart
final podcast = Podcast(...);
profileProvider.addPodcastToHistory(podcast);
```

### Podcast Player Screen
Update progress during playback:
```dart
profileProvider.updatePodcastProgress(
  podcastId,
  currentProgress,
);
```

## Navigation Flow

```
Learning Path → Profile (bottom nav)
Profile → Back to Learning Path (bottom nav)
Profile → Settings (header button)
Profile History Item → Podcast Player (tap)
```

## Data Persistence

Currently in-memory. To persist:

1. **Shared Preferences** (simple)
```dart
final prefs = await SharedPreferences.getInstance();
prefs.setString('profile_data', jsonEncode(profileData));
```

2. **Local Database** (recommended)
```dart
// Use sqflite or hive
await database.insert('podcast_history', historyItem.toJson());
```

3. **Cloud Sync** (advanced)
```dart
// Use Firebase or custom backend
await api.syncProfile(userId, profileData);
```

## Customization

### Change Colors
Edit `profile_screen.dart`:
```dart
color: AppTheme.primary,  // Change to your color
```

### Add New Stats
1. Add field to `ProfileProvider`
2. Add getter method
3. Create new stat card in UI
4. Update calculation logic

### Modify History Display
Edit `_buildPodcastHistoryItem()` in `profile_screen.dart`

## Future Enhancements

- [ ] Edit profile information
- [ ] Change avatar/photo
- [ ] Export learning data
- [ ] Share achievements
- [ ] Learning goals and targets
- [ ] Weekly/monthly reports
- [ ] Badges and achievements
- [ ] Social features (friends, leaderboards)
- [ ] Download history for offline viewing
- [ ] Filter/search history
- [ ] Delete history items
- [ ] Category-based statistics

## Testing

### Manual Testing Checklist
- [ ] Profile loads correctly
- [ ] Statistics display accurate data
- [ ] Podcast history shows all items
- [ ] Progress bars update correctly
- [ ] Navigation works between screens
- [ ] Empty state displays when no history
- [ ] Scrolling is smooth
- [ ] Tap actions respond correctly

### Test Data
Add mock podcasts for testing:
```dart
@override
void initState() {
  super.initState();
  _addMockData();
}

void _addMockData() {
  final profile = Provider.of<ProfileProvider>(context, listen: false);
  
  // Add some test podcasts
  for (int i = 0; i < 5; i++) {
    final podcast = Podcast(
      id: 'test_$i',
      title: 'Test Podcast $i',
      category: 'Technology',
      durationSeconds: 1800,
      createdAt: DateTime.now().subtract(Duration(days: i)),
      type: PodcastType.exploreTopic,
      topic: 'Test Topic',
    );
    
    profile.addPodcastToHistory(
      podcast,
      completed: i % 2 == 0,
    );
  }
}
```

## Performance Considerations

- History list uses `SliverList` for efficient scrolling
- Large lists are virtualized automatically
- Images are cached
- State updates are optimized with `notifyListeners()`

## Accessibility

- All interactive elements have tap areas ≥48px
- Sufficient color contrast ratios
- Semantic labels for screen readers
- Logical focus order

---

**Built with**: Flutter, Provider, Material Design 3
**Last Updated**: December 2025

