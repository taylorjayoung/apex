function inRectangle(rectangleCoords, pointCoords){
    //Rectangle Coordinates [[-3,3], [2,2], [2,-2], [-2, 2]]
    //point coordinates [1,2]
    //If the point lies on the boundary do we consider it inside the rectangle? 
    //no

        const xPoint = pointCoords[0]
        const yPoint = pointCoords[1]
    //define boundaries for each side
        //left bound
        const left = rectangleCoords[0][0]
        //upper bound
        const upper = rectangleCoords[0][1]
        //right bound
        const right = rectangleCoords[1][0]
        //bottom bound
        const bottom = rectangleCoords[2][1]

    // check x axes aginst left and right bounds
    //     if x point of pointCoord > left and < right
        //return true
    function checkX(left, right, point){
        return left < point < right ? true : false
    }
    //check y axis against upper and lower bound
        //if y point of pointCoord > bottom and < top
        //return true
    function checkY(bottom, top, point){
        console.log('bototm: ',bottom)
        console.log('top: ',top)
        console.log('point < top',point < top)

        return bottom < point < top ? true : false
    }

    //if both are within we return true
    //if any are false we return false
    const withinXrange = checkX(left, right, xPoint)
    const withinYrange = checkY(bottom, upper, yPoint)
    console.log('check y', checkY(bottom, upper, yPoint))
    return withinXrange && withinYrange
}

inRectangle([[-3,3], [3,3], [3,-3], [-3,-3]], [3,10])