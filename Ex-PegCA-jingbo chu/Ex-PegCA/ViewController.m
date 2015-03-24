//
//  ViewController.m
//  Ex-PegCA
//
//  Created by Steven Senger on 10/15/14.
//  Copyright (c) 2014 Steven Senger. All rights reserved.
//

#import "ViewController.h"
#import "PascalLayout.h"
#import "PegView.h"
#import "HoleView.h"

@interface ViewController ()
@property (weak,nonatomic) IBOutlet UIView * fieldView;
@property (strong,nonatomic) PascalLayout * pascalLayout;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *redoButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (strong, nonatomic) IBOutlet UITextField *pegCountField;
@property (assign, nonatomic) int numPeg;
@property (strong, nonatomic) NSMutableArray * stepList;
@property (strong, nonatomic) IBOutlet UITableView *stepTable;

@end

@implementation ViewController

@synthesize undoManager;

PegView * pegs[15];
HoleView * lastHole;

NSMutableArray * holes;
NSMutableArray * mids;
NSMutableArray * moves;

NSMutableArray * tracking;

#pragma mark Button Action Methods

- (void)updateUI
{
    if(self.undoManager.canUndo) {
        self.undoButton.enabled = YES;
    } else {
        self.undoButton.enabled = NO;
    }
    
    if(self.undoManager.canRedo) {
        self.redoButton.enabled = YES;
    } else {
        self.redoButton.enabled = NO;
    }
    [self.view setNeedsDisplay];
}


- (IBAction) undo {
    [self.undoManager undo];
    [self updateUI];
}

- (IBAction) redo {
    [self.undoManager redo];
    [self updateUI];
}

#pragma mark UITableViewDataSource Protocol Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stepList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    if (!cell) NSLog(@"no cell dequeued");
    cell.textLabel.text = [NSString stringWithFormat: @"%@ - %@",self.stepList[indexPath.row][@"step"],self.stepList[indexPath.row][@"date"]];
    return cell;
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Step Log";
}

- (NSMutableArray *) noteList
{
    if (!_stepList) _stepList = [NSMutableArray arrayWithCapacity: 10];
    return _stepList;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (void)scrollToLastestSeenMessageAnimated:(BOOL)animated
{
    NSInteger count = [self tableView:self.stepTable numberOfRowsInSection:0];
    if (count > 0) {
        NSInteger lastPos = MAX(0, count-1);
        [self.stepTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:lastPos inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark hole Methods

- (void) holeTouched: (HoleView *) sender {
    // NSLog(@"hole touched");
    if (pegs[sender.index]) return;
    if (lastHole) {
        lastHole.active = NO;
        [lastHole setNeedsDisplay];
    }
    sender.active = !sender.active;
    
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
        sender.transform = CGAffineTransformMakeScale(0.5,0.5);
        sender.transform = CGAffineTransformMakeScale(1,1);
        sender.transform = CGAffineTransformMakeScale(1.5,1.5);
        sender.transform = CGAffineTransformMakeScale(1.8,1.8);
        [UIView animateWithDuration:2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
            sender.transform = CGAffineTransformMakeScale(0.5,0.5);
            sender.transform = CGAffineTransformMakeScale(1,1);
            sender.transform = CGAffineTransformMakeScale(1.5,1.5);
            sender.transform = CGAffineTransformMakeScale(1.8,1.8);
            [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
                sender.transform = CGAffineTransformMakeScale(0.5,0.5);
                sender.transform = CGAffineTransformMakeScale(1,1);
                sender.transform = CGAffineTransformMakeScale(1.5,1.5);
                sender.transform = CGAffineTransformMakeScale(1.8,1.8);
                [UIView animateWithDuration:2 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse animations:^{
                    sender.transform = CGAffineTransformMakeScale(0.5,0.5);
                    sender.transform = CGAffineTransformMakeScale(1,1);
                    sender.transform = CGAffineTransformMakeScale(1.5,1.5);
                    sender.transform = CGAffineTransformMakeScale(1,1);
                } completion:nil];
            } completion:nil];
        } completion:nil];
    } completion:nil];
    
    lastHole = sender;
    [sender setNeedsDisplay];
}

#pragma mark peg move and recovery Methods

- (void) pegTouched: (PegView *) peg {
    //NSLog(@"peg touched");
    NSLog(@"peg index------%i in pegTouched",peg.index);
    if (!lastHole || !lastHole.active){
        NSLog(@"lastHole is nil");
        if(!lastHole.active )
            NSLog(@"active problem");
        return;
    }
    
    if ( ![self.pascalLayout index: peg.index canJumpTo: lastHole.index]){
        NSLog(@"cannot jump peg index:%i lastHole index:%i", peg.index, lastHole.index);
        return ;
    }
    
    int midInd = [self.pascalLayout indexBetween: peg.index and: lastHole.index];
    if (!pegs[midInd]) {
        NSLog(@"mid peg is nil");
        return;
    }
    
    [self.undoManager beginUndoGrouping];
    [self midPegMovement:pegs[midInd] ];
    [self movePeg:@{@"move":peg, @"lastHole":lastHole}];
    [self changeData:@{@"peg":peg,@"lastHole":lastHole, @"midPeg":pegs[midInd]}];
    [self.undoManager endUndoGrouping];
    
    if( self.numPeg == 5){
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Not bad" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    
    if(self.numPeg == 3 ){
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"U are great" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [myAlertView show];
    }
    
    if(self.numPeg == 1 ){
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"U are prefect" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [myAlertView show];
    }
}

-(void) changeData:(NSDictionary *) dict{
    PegView * peg = dict[@"peg"];
    HoleView * hole = dict[@"lastHole"];
    PegView * midPeg = dict[@"midPeg"];
    
    [mids addObject:midPeg];
    [moves addObject:[NSNumber numberWithInt:peg.index]];
    [holes addObject:lastHole];
    
    int midInd = midPeg.index;
    
    //update stepTable
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setValue:[NSString stringWithFormat:@"%i move,%i gone", peg.index, midInd] forKey:@"step"];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd/MM/yy HH:mm:ss"];
    [dictionary setValue: [formatter stringFromDate: [NSDate date]] forKey: @"date"];
    [self.stepList addObject: dictionary];
    [self.stepTable reloadData];
    [self scrollToLastestSeenMessageAnimated:YES];
    
    NSLog(@"changeData for peg:%i lastHole:%i midPeg:%i ", peg.index, hole.index, midPeg.index);
    
    pegs[peg.index] = nil;
    peg.index = hole.index;
    pegs[peg.index] = peg;
    hole.active = NO;
    [hole setNeedsDisplay];
    hole = nil;
    pegs[midInd] = nil;
    
    [self.undoManager registerUndoWithTarget:self selector:@selector(recoveryData:) object:@{@"moveAfter":peg,@"lastHole":[holes lastObject], @"midPeg":midPeg, @"moveBefore":[moves lastObject] }];
}

-(void) recoveryData:(NSDictionary *) dict{
    
    PegView * pegAfter = dict[@"moveAfter"];
    HoleView * hole = dict[@"lastHole"];
    PegView * midPeg = dict[@"midPeg"];
    NSNumber * pegBefore = dict[@"moveBefore"];
    
    pegs[midPeg.index] = midPeg;
    lastHole = hole;
    //lastHole.active = YES;
    
    [lastHole setNeedsDisplay];
    
    NSLog(@"recoveryData for pegAfter:%i lastHole:%i midPeg:%i pegBefore:%i", pegAfter.index, hole.index, midPeg.index,[pegBefore intValue]);
    
    pegs[pegAfter.index] = nil;
    pegAfter.index = [pegBefore intValue];
    pegs[pegAfter.index] = pegAfter;
    
    HoleView * h = [holes lastObject];
    pegs[h.index] = nil;
    
    [moves removeLastObject];
    [holes removeLastObject];
    [mids removeLastObject];
    
    //update stepTable
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setValue:[NSString stringWithFormat:@"%i back,%i appear", pegAfter.index, midPeg.index] forKey:@"step"];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd/MM/yy HH:mm:ss"];
    [dictionary setValue: [formatter stringFromDate: [NSDate date]] forKey: @"date"];
    [self.stepList addObject: dictionary];
    [self.stepTable reloadData];
    [self scrollToLastestSeenMessageAnimated:YES];
    
    
    [self.undoManager registerUndoWithTarget:self selector:@selector(changeData:) object:@{@"peg":pegAfter,@"lastHole":lastHole, @"midPeg":midPeg}];
}

-(void) movePeg:(NSDictionary *) dict{
    PegView * peg = dict[@"move"];
    HoleView * hole = dict[@"lastHole"];
    
    NSString *s = [NSString stringWithFormat:@"%lu", (unsigned long)[[tracking objectAtIndex:peg.index] count] ];
    
    [[tracking objectAtIndex:peg.index] setValue:[NSValue valueWithCGPoint: peg.center] forKey:s ] ;
    
    
    NSLog(@"movePeg for peg:%i lastHole:%i ", peg.index, hole.index);
    
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        peg.center = hole.center;
    } completion:nil];
    [self.undoManager registerUndoWithTarget:self selector:@selector(moveBackPeg:) object:@{@"move":peg, @"lastHole":hole}];
    
}

-(void) moveBackPeg:(NSDictionary *) dict{
    PegView * peg = dict[@"move"];
    HoleView * hole = dict[@"lastHole"];
    
    NSLog(@"moveBackPeg for peg:%i lastHole:%i ", peg.index, hole.index);
    
    int length = (int)[[tracking objectAtIndex:peg.index] count];
    NSValue * value = [[tracking objectAtIndex:peg.index] objectForKey:[NSString stringWithFormat:@"%i",  (length - 1)]];
    [[tracking objectAtIndex:peg.index] removeObjectForKey:[NSString stringWithFormat:@"%i",  (length - 1)]];
    
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        peg.center = [value CGPointValue];
    } completion:nil];
    [self.undoManager registerUndoWithTarget:self selector:@selector(movePeg:) object:@{@"move":peg, @"lastHole":hole}];
    
}



-(void) midPegMovement: (PegView *) mid {
    
    NSString *s = [NSString stringWithFormat:@"%lu", (unsigned long)[[tracking objectAtIndex:mid.index] count] ];
    
    [[tracking objectAtIndex:mid.index] setValue:[NSValue valueWithCGPoint: mid.center] forKey:s ] ;
    
    NSLog(@"midPegMovement for mid:%i ", mid.index);
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        mid.center = CGPointMake(mid.center.x, self.fieldView.bounds.size.width - self.fieldView.bounds.size.width / 20);
    } completion:^(BOOL finished) {
        //[imageView.layer setHidden:YES];
    }];
    [self.undoManager registerUndoWithTarget:self selector:@selector(midPegMoveBack:) object:mid];
    self.numPeg--;
    self.pegCountField.text = [NSString stringWithFormat:@"%i", self.numPeg];
}

-(void) midPegMoveBack:(PegView *) mid {
    NSLog(@"midPegMoveBack for mid:%i ", mid.index);
    int length = (int)[[tracking objectAtIndex:mid.index] count];
    NSValue * value = [[tracking objectAtIndex:mid.index] objectForKey:[NSString stringWithFormat:@"%i",  (length - 1)]];
    [[tracking objectAtIndex:mid.index] removeObjectForKey:[NSString stringWithFormat:@"%i",  (length - 1)]];
    [UIView animateWithDuration:0.8 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        mid.center = [value CGPointValue];
    } completion:^(BOOL finished) {
        //[imageView.layer setHidden:YES];
    }];
    [self.undoManager registerUndoWithTarget:self selector:@selector(midPegMovement:) object:mid];
    self.numPeg++;
    self.pegCountField.text = [NSString stringWithFormat:@"%i", self.numPeg];
}

#pragma mark reset Method

- (IBAction)reset:(UIButton *)sender {
    for( int i = 0; i < 15; i++ ){
        [pegs[i] removeFromSuperview];
    }
    
    for( int i = 0; i < [mids count]; i++ ){
        [mids[i] removeFromSuperview];
    }
    
    CGFloat width = self.fieldView.bounds.size.width;
    
    CGFloat pegSize = width / 10;
    pegs[0] = nil;
    for (int i = 1; i < 15; i++) {
        PegView * peg = [[PegView alloc] initWithFrame: CGRectMake(0,0,pegSize,pegSize)];
        [peg addTarget: self action: @selector(pegTouched:) forControlEvents: UIControlEventTouchUpInside];
        peg.opaque = NO;
        peg.layer.zPosition = 1;
        peg.center = [self.pascalLayout coordForIndex: i];
        peg.index = i;
        [self.fieldView addSubview: peg];
        pegs[i] = peg;
    }
    
    self.undoManager=[[NSUndoManager alloc] init];
    [self.undoManager setLevelsOfUndo:999];
    holes = [[NSMutableArray alloc] initWithCapacity:13];
    mids = [[NSMutableArray alloc] initWithCapacity:13];
    moves = [[NSMutableArray alloc] initWithCapacity:13];
    tracking = [[NSMutableArray alloc] initWithCapacity:14];
    for( int i = 0; i < 15; i++ )
        [tracking addObject:[[NSMutableDictionary alloc] init]];
    self.numPeg = 14;
    self.pegCountField.text = [NSString stringWithFormat:@"%i", self.numPeg];
    [self.stepList removeAllObjects];
    [self.stepTable reloadData];
}


- (void) viewDidLayoutSubviews {
    
    CGFloat width = self.fieldView.bounds.size.width;
    CGFloat scale = width / 6.0;
    CGFloat mid = width / 2.0;
    if( !self.pascalLayout ){
        self.pascalLayout = [[PascalLayout alloc] initWithBase: CGPointMake(mid, 1.2 * scale) andScale: scale];
        
        CGFloat holeSize = width / 20;
        for (int i = 0; i < 15; i++) {
            HoleView * hole = [[HoleView alloc] initWithFrame: CGRectMake(0,0,holeSize,holeSize)];
            [hole addTarget: self action: @selector(holeTouched:) forControlEvents: UIControlEventTouchUpInside];
            hole.opaque = NO;
            hole.layer.zPosition = 0;
            hole.center = [self.pascalLayout coordForIndex: i];
            hole.index = i;
            hole.active = NO;
            [self.fieldView addSubview: hole];
        }
        
        CGFloat pegSize = width / 10;
        for (int i = 1; i < 15; i++) {
            PegView * peg = [[PegView alloc] initWithFrame: CGRectMake(0,0,pegSize,pegSize)];
            [peg addTarget: self action: @selector(pegTouched:) forControlEvents: UIControlEventTouchUpInside];
            peg.opaque = NO;
            peg.layer.zPosition = 1;
            peg.center = [self.pascalLayout coordForIndex: i];
            peg.index = i;
            [self.fieldView addSubview: peg];
            //           [[tracking objectAtIndex:i] setValue:[NSValue valueWithCGPoint: peg.center] forKey:@"0"];
            pegs[i] = peg;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.undoManager=[[NSUndoManager alloc] init];
    [self.undoManager setLevelsOfUndo:999];
    holes = [[NSMutableArray alloc] initWithCapacity:13];
    mids = [[NSMutableArray alloc] initWithCapacity:13];
    moves = [[NSMutableArray alloc] initWithCapacity:13];
    tracking = [[NSMutableArray alloc] initWithCapacity:14];
    for( int i = 0; i < 15; i++ )
        [tracking addObject:[[NSMutableDictionary alloc] init]];
    self.numPeg = 14;
    self.pegCountField.text = [NSString stringWithFormat:@"%i", self.numPeg];
    self.stepList = [[NSMutableArray alloc] initWithCapacity:10];
    [self.stepTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
