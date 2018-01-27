image = imread('biggerDuck.jpg');

puzzleImage = createPuzzleFrom(image, 5, 5);
%imtool(image);

imshow(puzzleImage);

