//Dynamic Programming Problems taken from Ernest Davis' Fundamental Algorithms course at NYU - Summer 2015

/*
Problem 1
Problem Set 8
A. Give an O(n2) algorithm that, given a sequence S, finds the longest subsequence that first increases then decreases. For instance, in the sequence S = [10, 4, 5, 11, 2, 7, 4, 3, 9] the longest such subsequence is [4,5,11,7,4,3]. The subsequence does not have to be consecutive. (Hint: Use two arrays, one for increasing subsequences and the other for decreasing subsequences.)
B. Consider the modification of (A) which requires that you find the longest subsequence that first increases, then decreases, and does not repeat any values. For instance, given the input sequence, 10,4,5,11,2,7,4,3,9 the subsequence 4,5,11,7,4,3 would be disallowed because the value 4 is repeated. The longest valid subsequence would 4,5,11,7,3. Explain why the kind of dynamic programming technique used in (A) cannot be adapted to solve this problem.
*/

//Problem #1
/* takes sequence as argument
 * returns longest subsequence, non-consecutive, that increases then decreases
 * Author: Evan Johnson for Basic Algorithms Problem Set #8 - 7/22/15*/
func increaseThenDecrease(s : [Int]) -> [Int] {
    if (s.count == 1) { return s }
    //declare arrays and then initialize first values
    var tInc : [Int] = []
    var pInc : [Int] = []
    var tDec : [Int] = []
    var pDec : [Int] = []
    var tIncThenDec : [Int] = []
    tInc.append(1)
    pInc.append(-1) //can't put type nil in Int array in swift, -1 used instead
    tDec.append(0)
    pDec.append(-1)
    //for each element in the sequence, starting with the second element
    for ( var i = 1; i < s.count; i++){
        //initialize values as for loop continues, tDec and pDec are initialized here
        //because the loop to process them will be working backwards
        tInc.append(1)
        pInc.append(-1)
        tDec.append(1)
        pDec.append(-1)
        //pIncThenDec.append(-1)
        for ( var j = 0; j < (i); j++){
            //check for increasing sequence
            if ( s[j] < s[i] && tInc[j] >= tInc[i]) {
                tInc[i] = tInc[j] + 1
                pInc[i] = j
            }
        }
    }
    //similar process for decreasing substring
    for ( var i = s.count-2; i >= 0; i--){
        for ( var j = s.count-1; j > i; j--){
            //check for decreasing sequence
            if ( s[j] < s[i] && tDec[j] >= tDec[i]) {
                tDec[i] = tDec[j] + 1
                pDec[i] = j
            }
        }
    }
    //populate array of longest subsequence of increasing then decreasing order
    //where s[i] is the high point of the subsequence and tIncThenDec[i] is the length
    //for that high point
    //additionally keep track of the index of the largest value and that value
    var max = 0
    var maxIndex = 0
    for (var i = 0; i < s.count; i++){
        tIncThenDec.append(tInc[i] + tDec[i] - 1)
        if (tIncThenDec[i] > max){
            max = tIncThenDec[i]
            maxIndex = i
        }
    }
    //declare and initialize array that will contain the subsequence to be returned
    var longest : [Int] = []
    for ( var i = 0; i <= max - 1; i++){
        longest.append(0)
    }
    //populate the array of the subsequence using path recovery in while loops
    //increasing and decreasing sections found seperately
    var i = maxIndex
    while ( i != -1) {
        longest[tInc[i] - 1] = s[i]
        i = pInc[i]
    }
    var j = maxIndex
    var decLength = tDec[j]
    while ( j != -1) {
        longest[longest.count - decLength] = s[j]
        j = pDec[j]
        decLength--
    }
    return longest
}
increaseThenDecrease([10, 4, 5, 11, 2, 7, 4, 3, 9]) //random - example problem
increaseThenDecrease([5]) //single element
increaseThenDecrease([-5, 3, -2, 7, 4, 9,-3, -2, 0]) //with negative numbers and a 0
increaseThenDecrease([1, 2, 3, 4]) //all increasing
increaseThenDecrease([4, 3, 2, 1]) //all decreasing




/*
Problem 2
The KNAPSACK problem is defined as follows: You are given a collection of objects. Each object X has a value X.value and a weight X.weight. You are packing a knapsack and there is a maximum weight W that you can carry. The problem is to choose the objects so that their total weight is at most W, and their total value is as large as possible.
In general, if the weights are floating point numbers or large integers, then the problem is believed to be intractable (that is, there is no efficient solution.) However, if all the weights involved are small integers, then there is a solution which is polynomial time in W.
Find an efficient dynamic programming solution to the problem, on the assumption that the weights and W are all small positive integers. State the running time of your algorithm as a function of n, the number of objects, and W.
Write the algorithm so that the optimal set (not just the optimal value) can be easily recovered, and describe how the set is recovered.
Hint: For k = 1 to W, for j = 1 to n, find the most valuable subset of the first j objects whose total weight is exactly k.
*/

//Problem #2 - knapsack problem
//Author: Evan Johnson for problem set #8 - 7/23/15

//setup
//define an item to have a value and a weight
struct Item {
    var value : Int = 0
    var weight : Int = 0
}
//create some items
let item1 : Item = Item(value : 150, weight : 50)
let item2 : Item = Item(value : 140, weight : 35)
let item3 : Item = Item(value : 90, weight : 25)
let item4 : Item = Item(value : 70, weight : 20)
let item5 : Item = Item(value : 30, weight : 5)
let item6 : Item = Item(value : 8, weight : 1)
//max weight allowed
let MaxW : Int = 50
//collection of the items in an array
let myItems : [Item] = [item1, item2, item3, item4, item5, item6]

/*returns:
 * K : 2-dimensional integer array storing the max value of all items up to and including the current item for
 *     every weight at and below W that does not exceed the current weight
 * P : 2-dimensional integer array tracking if item is kept or not, 1 if so, 0 if not
 */
func knapSack(W : Int, items : [Item], n : Int) -> ( K :[[Int]], P : [[Int]]){
    //declare and initialize arrays for max value and path
    var K = [[Int]](count: W+1, repeatedValue: [Int](count: n+1, repeatedValue: 0))
    var P = [[Int]](count: W+1, repeatedValue: [Int](count: n+1, repeatedValue: 0))
    for ( var k = 0; k <= W; k++){
        for ( var j = 0; j <= n; j++){
            //initialize first row and column to be 0, P will stay 0 since these are extra indices added to make the algorithm work properly without an out of bounds error
            if ( k == 0 || j == 0){
                K[k][j] = 0
            }
            //if the weight of the current item fits in the current weight being examined
            else if (items[(j-1)].weight <= k) {
                //if adding the value of the current item to the max value at the remaining weight for all items before the current, then adding the current item helps - mark the item as to be kept and set the value of K at current location to the previously calculated sum
                if (items[j-1].value + K[k-items[j-1].weight][j-1] > K[k][j-1]){
                    K[k][j] = items[j-1].value + K[k-items[j-1].weight][j-1]
                    //mark item to be kept
                    P[k][j] = 1
                }
                //else adding the current item wont help, retrive value from above and dont mark to be kept
                else {
                    //set value at current place in K to the value in K bordering to the top
                    K[k][j] = K[k][j-1]
                    //mark item to not be kept
                    P[k][j] = 0
                }
            }
            //else the weight of the current item is greater than the current weight
            else {
                //set value at current place in K to the value in K bordering to the left
                K[k][j] = K[k-1][j];
                //mark item not to be kept
                P[k][j] = 0
            }
        }
    }
    return (K, P)
}

//returns array with the items to be included in the knapsack
func pathRecover (items: [Item], P : [[Int]], n : Int, W: Int) -> [Item] {
    var itemsInKnapsack : [Item] = []
    var R = W //R tracks weight remaining
    //starting with the last item check if its kept
    for ( var i = n; i > 0; i--){
        //if item is kept, add it to the array to be returned and subtract its weight from the remaining weight
        if ( P[R][i] == 1){
            R = W - items[i - 1].weight
            itemsInKnapsack.append(items[i - 1])
        }
    }
    return itemsInKnapsack
}

//sample test
var myKnapsack = knapSack(MaxW, items: myItems, n: myItems.count)
pathRecover(myItems, P: myKnapsack.P, n: myItems.count, W: MaxW)



/*
Problem 3:
Let T be a binary tree whose leaves are labelled with numbers. For any internal node N of T, we define the imbalance of N to be the absolute value of the difference between the sum of values in the left subtree and the sum in the right tree. Define the overall imbalance of T to be the maximum imbalance of all internal nodes of T.
Given a sequence of numbers S, the most balanced tree for S is the tree whose leaves are S in the specified order with the smallest overall imbalance.
Write a dynamic programming algorithm that computes the most balanced tree for any sequence S. Hint: Use two arrays. S[i,j] is the sum of elements i through j. B[i,j] is the overall imbalance of the best subtree spanning elements i through j.
1
For instance, for the sequence S = 4, 3, 1, 7 there are five possible trees. The pictures in the attached documentation pdf show the trees, with each node labelled with its sum S and its imbalance I. The most balanced tree is T2, with an overall imbalance of 2.

*/

//Problem 3 - Balancing Trees
//Author: Evan Johnson for problem set #8 - 7/25/15
func balancedTree(a : [Int]) -> Int {
    //setup
    let n = a.count
    var S = [[Int]](count: n + 1, repeatedValue: [Int](count: n + 1, repeatedValue: 0))
    var B = [[Int]](count: n + 1, repeatedValue: [Int](count: n + 1, repeatedValue: -1))
    for ( var k = 1; k <= n; k++){
        S[k][k] = a[k - 1]
    }
    //for each length 2 thru length of the sequence
    for ( var length = 2; length <= n; length++){
        //starting at i = 1, representing the first element in the sequence, till another sequence with current length wont fit
        for ( var i = 1; i <= n + 1 - length; i++){
            //set current bext to infinity
            var best = Int(Int.max)
            //set point that will be looped till
            let j = i + length - 1
            //iterate thru values i - j
            for ( var m = i; m <= j - 1; m++){
                //calculate sum where S[i][j] is the sum of elements i thru j
                let sum = S[i][j-1] + a[m]
                S[i][j] = sum
                //determine the imbalance of new node at it's level
                let tempNew = abs(S[i][m] - S[m+1][j])
                //initialize variables to hold imbalance of children, if children are not leaves (as calculated in the if statments) set the imbalance found at the node
                var leftI = 0
                var rightI = 0
                if ( i != m ) {leftI = B[i][m]}
                if ( m+1 != j ) {rightI = B[m+1][j]}
                //the overall imbalance of the new node will be the max of it's imbalance, and it's two children, if children are leaves their imbalance will remain 0
                let newOverallI = max(tempNew, leftI, rightI)
                //if the overall imbalance is better than the current best, set the best to this node's imbalance
                if (newOverallI < best){
                    best = newOverallI
                    B[i][j] = best
                }
            }
        }
    }
    //return the best overall balance for what would be the top node
    return B[1][n]
}

balancedTree ( [4,3,1,7] )

