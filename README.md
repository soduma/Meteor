[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fsoduma%2FMeteor&count_bg=%23AA0909&title_bg=%230817A4&icon=hyundai.svg&icon_color=%23E7E7E7&title=&edge_flat=false)](https://hits.seeyoufarm.com)

### `Meteor`
📕 알림 창에 메모해보세요

![logo210408](https://user-images.githubusercontent.com/69476598/119452474-6053f080-bd71-11eb-840c-fbfa2998a811.png)

### 🍀 Meteor는 아이폰의 기본앱 중 미리알림에서 영감을 받아 제작한 투두 앱입니다.
>대부분의 투두 앱이 가지고 있던 '하루 중 지정된 시각'에 '지정된 알림'을 받던 방식을 벗어나   
>**입력한 내용을 즉시 알림창에서 푸시받는** 그 자체로 하나의 메모장으로 사용할 수 있도록 구현하였습니다.

*한국어, 영어에 대해 현지화가 되어 있습니다.*
- [App Store](https://apps.apple.com/kr/app/meteor/id1562989730)

---

## 사용 기술
- Language : Swift
- Framework : UIKit, Foundation, WidgetKit
- Library : Firebase
- Etc: [Upsplash](https://source.unsplash.com/random) (Random 이미지 생성용) 

  

### 주요 기능
- 텍스트 필드에 입력한 내용을 Push Notification으로 receive할 수 있도록 구현함.
- 또한 Push를 사용자가 지정한 시간 간격으로 계속해서 받을 수 있고, Push가 도착할 때까지 남은 시간을 표시하는 Timer 구현함.
- UICollectionView를 사용하여 탭 하단의 View에서 입력된 내용을 표현, Data의 수정과 삭제가 가능함.
- Link를 통해 받아온 Image를 ImageView에 담아 이를 Widget에서도 볼 수 있도록 구현함.

### 신경 쓴 부분
- 기능상 Alert 권한이 필수적이기 때문에 denied 되었을 경우 사용자에게 알리고, Background에서 Foreground로 돌아올 때 자연스러운 사용이 가능하도록 구현함.
- Background Task에 대한 이해가 부족해 Timer가 계속 맞지 않는 것을 발견하고, Timer가 처음 동작할 때의 Date를 받아와서 이를 이용해 Push까지의 남은 시간을 표현하도록 함.
