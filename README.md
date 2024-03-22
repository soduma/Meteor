<!-- [![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fsoduma%2FMeteor&count_bg=%23AA0909&title_bg=%230817A4&icon=hyundai.svg&icon_color=%23E7E7E7&title=&edge_flat=false)](https://hits.seeyoufarm.com) -->

### `Meteor`
📕 알림 창에 메모해보세요

![logo210408](https://user-images.githubusercontent.com/69476598/119452474-6053f080-bd71-11eb-840c-fbfa2998a811.png)

### 🍀 Meteor는 아이폰의 기본앱 중 미리알림에서 영감을 받아 제작한 투두 앱입니다.
>대부분의 투두 앱이 가지고 있던 '하루 중 지정된 시각'에 '지정된 알림'을 받던 방식을 벗어나   
>**입력한 내용을 즉시 알림창에서 푸시받는** 그 자체로 하나의 메모장으로 사용할 수 있도록 구현하였습니다.

*한국어, 영어에 대해 현지화가 되어 있습니다.*
- [App Store](https://apps.apple.com/kr/app/meteor/id1562989730)

---

### 사용 기술
- Language : Swift
- Framework : UIKit, SwiftUI, WidgetKit, ActivityKit
- Library : SnapKit, Alamofire, Lottie, Firebase
- Etc: [Unsplash](https://source.unsplash.com/random) (Random 이미지 생성용) 

### 주요 기능
- Local Push Notification으로 텍스트 필드에 입력한 내용을 receive할 수 있음.
- Push를 사용자가 지정한 시간 간격마다 받을 수 있고, receive할 때까지 남은 시간을 표시하는 Timer 구현.
- 같은 사용법으로 Live Activities에서 내용을 확인 할 수 있도록 함.
- URL를 통해 받아온 Image를 Widget에서 볼 수 있도록 구현.

### 신경 쓴 부분
- 기능상 Alert 권한이 필수적이기 때문에 denied 되었을 경우 사용자에게 알리고, 설정 변경 후 Background에서 Foreground로 돌아올 때 자연스러운 사용이 가능하도록 구현함.
- Background 상태에서 Active로 돌아왔을 경우를 위해, Timer가 처음 동작할 때의 Date를 받아와서 이를 이용해 Push까지의 남은 시간을 표현하도록 함.
