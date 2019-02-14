//
//  InfoConstant.swift
//  Golfication
//
//  Created by Rishabh Sood on 13/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import Foundation

struct StatsIntoConstants{
    
    static let averageRoundScores = "While we're busy working on swing fixes, training aids, and that new tip from our YouTube Coach, we mustn't forget that the primary objective of golf is to shoot lower scores. Average Round Scores pronounce the verdict, and all other stats merely tell us how we arrived at it! In fact, data crunched from thousands of rounds played using the Golfication App tell us exactly how much you can expect to score, given your handicap. Tell us your handicap and average scores in the comments below."
    
    static let scoreDistribution = "Have you ever broken 100? Do you shoot in the 80s? Or are you going to challenge Par? Based on our handicap level, we have different objectives. This graph tells you the story of your progress, and your goal is to shift the graph towards the left! Seems easy enough, right?"
    
    static let scoring = "\"When I play a bad round, I'm always asking myself if I should've really gone for it - and tried making a few more birdies (net)... or if I played bad because I couldn't save par on other holes.\" - Kal Peterson, N. Y. (HCP 12). As golfers, we always face the question: Lay Up, or Go for It? Should we play aggressive, or more measured golf? And usually, our emotions decide how we play. However, we'd play better golf if we made data-driven decisions. If you make some birdies (net) and more double bogeys or worse (Net, in comparison with your handicap category), then you could try a more conservative, risk-free game. Whereas, if you're just making Par (Net) and a few Bogeys (Net), then you're the ideal candidate to Go For It."
    
    static let parAverage = "Single digit handicap golfers love the Par-5s, while Bogey Golfers fear it. Know why? The Par-5 Holes give professionals & low HCP golfers the chance to go for it and make birdie. If you're long and accurate off the tee and from the fairway, chances are you'll love these holes. But for the average weekend golfer, longer holes offer more chances of playing bad shots. So Par 5s become tougher as you move up the Handicap Categories."
    
    static let penalties = "This stat in the Golfication Overview section is a no-brainer. You want this number to be low. Hitting the ball into hazards and out of bounds really affects your scorecard, and you'll be delighted to see a downward trend here. We haven't yet set up benchmarks for Penalties based on Handicap, as this stat varies dramatically from one course to another. The best way to utilize this stat is to view its trend for a particular course. (Course with more water and Out of Bounds opportunities will see a higher number here)."
    
    static let spreadOffTheTee = "Being long matters, but only if you can keep it straight. This is a powerful Golf Stat from Golfication, that visually shows you how good - or ugly - your Driving really is. In fact, you can also filter this by club - e.g. to see how well you drive the ball using driving irons. This stat considers only Par 4s and Par 5s, where your objective is to hit the ball long. It does not include Par 3 Tee-Shots, where distance-control becomes critical."
    
    static let DriveAccuracy = "This is the traditional \"Fairways Hit\" stat, that we made more meaningful for our golfers - through benchmarks and insights. If you're hitting 8 fairways out of 14 as a 12-HCP golfer, you're much better than golfers like you. But the same Fairways Hit stat would make you just an average 5-HCP golfer. It's also really interesting to note that golfers tend to miss right more often than left. The misses become more significant for 20+ HCP golfers."
    
    static let driveDistance = "This golf stat considers distance off the tee on Par 4s and Par 5s. The colours of the shots tell you if you have hit or missed the fairway, but it doesn't take into account the magnitude of your miss. So a red dot might indicate a shot in the first cut of rough, or deep in the trees. To understand your driving better, look at the Golfication Stat called \"Strokes Gained - Off The Tee\". A fully green chart that's moving upwards is indicative of great progress in this area."
    
    static let fairwayHitTrend = "This golf stat is a snapshot of your Off The Tee performance. Are you hitting more fairways now than you were two weeks ago? The stat automatically shows you how many fairways you hit out of all the attempts you made. Example: Hitting 6 fairways out of 7 in a nine-hole round is remarkable; in contrast, hitting 6out of 14 is poor."
    
    static let fairwayHitLikeliness = "Is your driving accuracy lying? Can a few bad rounds (perhaps, at a new course) ruin your great Driving Accuracy stats? Consider this: a golfer who hits 10, 10, 11, 2, 4, 6, 7, 4, 5, 10 fairways in 10 rounds is qualitatively different from a golfer who hits 6, 7, 7, 7, 7, 6, 7, 7, 7, 7. But both golfers hit exactly 6.8 Fairways per Round. Why is this? The first golfer has great potential but has been very inconsistent over these ten rounds, but the second golfer is an average but consistent driver. I would be far happier as Golfer 2, but I have friends who seek the thrills of Golfer 1."
    
    static let approachAccuracy = "In the good old days, we used to mark GIRs with a small check mark in our notes to keep a record of greens hit. Some of us went a step further to record our misses. Golfication now provides you with a Powerful Golf Stat, which visually represents your Approach Accuracy. White dots show balls that end up on the green; red dots indicate balls off the green. For the Approach stats, we only consider non-tee shots which are played with the objective of hitting the green. Our smart A.I. Caddie, Eddie, understands just which shots you play with the intent of \"going for the green\". This could be the second, third, or even the fourth shot in a Par 5; it almost certainly is the first shot on every Par 3."
    
    static let GIR = "Our traditions are rooted in meaning. At Golfication, our data scientists believe that Traditional Golf Stats hold the key to Golf Improvement. We go one step further to make a good ol' stat like GIR more useful, by showing you the difference between your GIR Chances with a Fairway Hit, and your GIR Chances with a Fairway Miss. Approach-Shots played from the rough tend to drag this stat down!"
    
    static let holeProximity = "If you're trying to hit the green from outside chipping radius (shots within Chipping Range are included in Around The Green stats), then your shot stats will appear here. Golfication provides you Hole Proximity stats on approach to tell you how close you got to the hole on your approach attempt. If you hit the green and three-putt, it doesn't necessarily mean you are a miserable putter. It could also mean that you aren't getting close enough to the holes where you make GIR. This stat tells you what you really ought to focus on!"
    
    static let girTrend = "This golf stat is a snapshot of your Approach performance. Are you hitting more greens now than you were a month ago? The stat automatically shows you how many greens you hit out of all the attempts you made. Example: Hitting 5 greens out of 9 in a nine-hole round may be alright; in contrast, hitting 5 out of 18 is abysmal."
    
    static let girLikeliness = "Just like the Fairway Likeliness golf stat, this stat shows you the consistency of your GIR Performance. A high variance in this stat (if you hit different number of greens each time) means you're more inconsistent than a golfer who constantly hits the same number of greens every round."
    
    static let chippingAccuracy = "The scoring zones \"around the green\", are the places from where you can attack the pin directly with your wedges and shorter irons. This stat captures all those shots where you shouldn't just be trying to get on the green, you should be trying to get in the hole! This Chipping Accuracy visual golf stat captures your dominant miss direction e.g. you tend to chip it past the hole by 10 feet."
    
    static let chipUpDown =  "When you have a shot at the pin from the fairway or the rough around the green, it counts as a Chipping: Up & Down opportunity. This stat aims to improve your chipping / scrambling performance, and is independent of whether you make Par or not. Your fifth shot, taken from 30 yards from the pin, on a Par 4, will still count in this stat (although you can only make double-bogey in the best case scenario)."
    
    static let chipProximity = "This is a scatter plot which helps you visualize your chipping accuracy from the fairway and rough; it does not include bunker-shots. The helpful insight from our A.I. Caddie, Eddie, tells you how long a putt you leave after chipping."
    
    static let sandUpDown = "Our A.I. Caddie, Eddie, feels that bunker-shots require specific, dedicated focus. They mustn't be clubbed with other stats. When you're in a greenside bunker, your skill level depends on whether you can get up and down in two strokes. This sand-save stat simply shows you the number of times you holed-out from a greenside bunker in two strokes, divided by the total number of opportunities you had."
    
    static let sandAccuracy = "This is a scatter plot which helps you visualize your bunker-shot accuracy from the greenside bunker; it does not include chipping from the fairway or rough. The helpful insight from our A.I. Caddie, Eddie, tells you how long a putt you leave after a shot from the sand."
    
    static let sandProximity = "You ought to be attacking the pin, trying to hole out, or leaving yourself with the shortest putt possible after a greenside bunker shot. This stat captures the lengths of putts you leave after a sand shot. The lower this stat, the better your sand technique is."
    
    static let puttsPerHole = "This is a traditional Golf Stat going back centuries! Golfication tells you the number of putts you make per hole, on average. You can filter this stat to see how you putt on any particular course. This stat also gives you a trend: are you getting better or worse?"
    
    static let puttsBreakup = "A regulation scorecard typically allows you two-putts to make Par on any hole. However, we don't always two putt. Sometimes, we 3-putt, and on the rarest of occassions, we chip in from the fairway. Our A.I. Caddie, Eddie, realized that golfers of each handicap have specific 0-, 1-, 2-, 3- and 4- Putt tendencies. This insight from the caddie tells you how different you are from other golfers of your HCP."
    
    static let puttVersusHandicap = "If you compared your putting versus other golfers of your handicap, how would you fare? Do you putt better or worse than other golfers like you? And what does it take to improve your putting to a level where you can challenge better golfers? See for yourself in this useful golf putting stat from Golfication."
    
    static let strokesGainedPerRound = "The PGA Tour breaks down the stats of its top professional golfers into four parts: Off-The-Tee, Approach, Around-The-Green, and Putting. At Golfication, we bring these stats from the Tour to the everyday golfer. Using this methodology, you can understand your performance in each segment of the game - each of which requires different skills and mindsets. The Strokes Gained Stat assesses your shots against statistical baselines. How does this work? Suppose you hit a 257 yd shot into the rough, then hit your approach shot 110 yards (10 yards short of the green), then chip up and two-putt for bogey, where did you go wrong? Was it your errant tee-shot, your short-approach which led to a missed GIR, poor chipping that landed too far from the hole, or the missed approach putt? Strokes Gained methodology uses data from other golfers to give each of your shots individual grades. So now you can evaluate your hole-performance as a sum of shots of differing qualities. You may have lost 0.3 strokes on your tee-shot and lost another 0.8 strokes on approach. Your stats may tell you that your chip shot actually gained you 0.1 strokes, but your putts let you down.  Golfication uses data from thousands of other golfers of different handicap categories to set up suitable baselines for your game. How does this help? This is useful because you need to compare yourself to a relevant skill level. Comparing an 18-Handicap golfer with a PGA Tour Professional would result in nonsensical insights. So Eddie, the A.I. Caddie, carefully groups you with other golfers of your skill level while delivering these insights."
    
    //Off the Tee: Swing & Consistency
    
    static let approachSwingConsistency = "Can a better, more-consistent swing technique really improve your shots? This is a powerful composite metric that analyses your swing and your shot-outcome, with each of your clubs. Club Control is a measure of how much confidence you can place on each of your golf clubs."
    
    //Around the Green: Swing & Consistency
    
    static let puttingApproachPuttHoleOut = "Your approach putt performance is the average distance to the hole after your first putt. For PGA Tour golfers, this stat is almost always under 3 feet, which just goes to show how good they are. Your Hole-Out distance is the average distance from where you're able to sink the ball with the putter."
    
    // MARK: Smart Caddie
    static let clubDistance = "Golf A.I. Eddie shows you smart distances for each of your clubs, when you don't mishit them. Using an algorithm that takes into account all your previous shots and your swing metrics (only if you are a Golfication X User), your Club Distance stats eliminate the outliers. For example, an 80 yard shot with the driver would not be added to this stats, as it's probably due to a mishit."
    
    static let clubRange = "Similar to the Club Distance Stat, this golf stat discounts your mishit shots. Topped, shanked and duffed shots typically don't show up in your club range. Your Club Range is the range of distances you hit with each of your clubs. The smaller your club range over a long period of time, the more confidence you can gain from this stat!"
    
    static let shortGame = "Golfication X brings you the Short Game Notebook. Using this stat, you can visualize the distance of your wedges and short-irons for a given swing technique. Golfers tend to internalize this knowledge over time, and this leads to more GIRs and great Approach-confidence. For example, won't it be amazing to know that your quarter-swing shots with the pitching wedge go exactly 30 yards, whereas your half-swing chip shots end up 20 yards further? This is precisely the knowledge you need to improve in the Scoring Zones."
    
    static let clubUsage = "Apart from the putter, that we use a LOT, we tend to have favourites among the other clubs in the bag. Example: This golf stat shows you just how often you use the 3-Wood in comparison to the 7-Iron. The more often you go for a particular club, the more it influences your overall score. So you had better be good with it!"
    
    static let strokesGainedPerClub = "What if you could know exactly how much better you are than your buddy with the Driver? But have a sneaky feeling he outplays you with a driving irons? Look at this stat to see how much better or worse you are with each club, as compared to other golfers of your handicap. Golfication uses data from thousands of rounds to help you focus on the right areas!"
    
    static let control = "Club Control is a powerful metric that measures the technique as well as stability of your golf swing. In short, it's a relative measure of how well you are swinging each of your golf clubs. This radial graph is designed to help amateurs understand the weakest links in their Golf Bag."
    // MARK: End Smart Caddie

    static let swingScore = "This composite metric measures the overall \"goodness\" of your Golf Swing. It takes into account a number of factors like your tempo, path, backswing angle, clubhead speed, sweetness of impact, and projected ball flight. This is a score out of 100, and is computed differently for each of your clubs. Scores in the 70s and 80s are average. 90+ scores indicate that your swing is really working for you!"
    
    static let clubheadSpeed = "PGA Tour Professionals generate average speeds of 112 mph with the driver, 100 mph with a 3-wood, 93 mph with a 7-iron and 82-mph with a sand wedge. Clubhead speeds vary between one handicap category and another, and also between men and women. For example, LPGA Tour Professionals generate 98 mph, 90 mph, 81 mph, and 72 mph respectively with the same clubs."
    
    static let clubTempo = "A golf professional's average time for the backswing is 0.82 seconds, with an additional 0.27 seconds to make the down swing to impact. That is an ideal ratio of 3:1. Most amateurs get into trouble with inconsistent changing tempo from swing to swing. A consistent swing tempo helps amateurs rapidly improve their ball striking ability."
    
    static let swingPath = "Swing Path measures how closely your backswing plane matches your downswing plane. Ideally, the higher the match, the better the golf. But certain golfers tend to have natural out-to-in or in-to-out swings that really work for them! If your swing path differs from the ideal 0 degree path but results in good Club Control and Consistency, your Swing Path goals are automatically adjusted by Golfication."
    
    static let gripSpeed = "While Clubhead Speed is based on the length of your club and the properties of the shaft, your grip speed remains fairly consistent across all clubs. This is the speed generated at the grip of the golf-club, by movement of the golfer's body, shoulders, arms and wrists."
    
    static let backswingAngle = "This swing stat is a measure of the angle between the club's position at the top of the backswing and its initial position at address. A textbook full-backswing is complete at a Backswing Angle of 270-degrees: i.e. with the club overhead, parallel to the ground below and pointing directly at the target. Underswinging the golf club results in lower clubhead speed at impact, and loss of distance on the ball. Overswinging the golf-club (angle above 270) may lead to poorer control, and higher chances of off-center hits. This stat is also critical for the short game, when golfers play deliberate three-quarter, or half-swing shots with wedges. This metric has a direct impact on the golfer's Short Game Notebook."
    
    static let swingConsistency = "\"Under pressure, avoid the urge to get hyper-technical with your swing,\" say the best instructors on the planet. Think less, reduce stress. Start with a good old-fashioned deep breath. And imagine the last great drive you hit. Try to keep it all positive. Working on your Swing Consistency can relax you even in the toughest of situations; you will be relieved to know that you can hit the exact same swing one more time. And this really takes the pressure off. The Swing Consistency Stat is a composite metric based on other swing parameters."
    
    static let practiceToGameTransition = "How many times have we hit the ball pure at the range, and failed to replicate these shots during a game? Most amateurs develop much better control of distance and trajectory on the Practice Range, than on the Golf Course. This may be due to a multitude of factors, especially the mental side of Golf. This key metric tells you exactly how much your Swing Score & Consistency vary between the Range and the Course, and is an essential part of evaluating the mental side of your game."
}
