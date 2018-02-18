# Puzzle Me Not
CSSE463 Image Recognition Project - Rose-Hulman Institue of Technology

## Objective
Solving Puzzles by hand can take a very long time. Our overarching goal is simple; we want to solve puzzles. The puzzles that we attempt to solve will be standard jigsaw puzzles. The stretch goal for this project is to be able to take a picture of a puzzle, partially complete or not, and present the user with a mapping of pieces in their image to where the piece belongs in the completed puzzle. 

## Images
A working set of images can be found at this drive: https://drive.google.com/drive/folders/12BzvU03my8N7xM_6qpPE8bCobpu-8FAE 

## Constraints
Standard JigSaw puzzle pieces
Using largely edge features - May use colors at edges to break possible connection ties
No 'masochistic' puzzles - puzzles that are arbitrarily hard for the sake of being hard
Puzzle pieces need to start in their correct orientation - Might change this later

## Milestones
  0. Extract Puzzle Pieces from an Image.
      - We need a way to separate puzzle pieces from their background.
  1. Isolate "border" Puzzle Pieces. 
      - Border pieces are inherently unique as they have at least one flat edge. Once these pieces are isolated, they can be combined to solve the perimeter.
  2. Learn how to Describe Edges
      - We need to find a way to extract just enough information from the edges of the pieces to reduce the amount of calculations and time required to run the puzzle solver.
  3. Two Piece Connection Validator
      - Now that edge information has been extracted, we need a way to see if the pieces actually fit together. 
  4. Solve the Border of the Puzzle
      - Use the Connection Validator to piece together the border of the puzzle
  5. Solve the Interior of the Puzzle
      - Use the Connection Validator to piece together the inside of the puzzle
  6. Reworking Puzzle Solving to Perform on 'Real Images'
      - This will involve taking into account potentially, noise, camera angle, tilted pieces.
  7. Extend Functionality to Recognize Partially Solved Puzzles
      - Now that a puzzle can be solved, we need to recognize and handle one that is partially completed. This is saved for last, because it will require a complete overhaul of most of the edge detection and connection validation logic.
            
## Documentation
 - [Process Notes](https://docs.google.com/document/d/1dFlcskbwAm6e1XdTNDeyerxvmVqD_4IM4_7pSn7M_Hk/edit?usp=sharing)
    - Used for jotting down notes about things that were tried, how they worked/didn't work, and keeping track of the process
    - Better detail provided in final report
 - [Final Report](https://www.sharelatex.com/project/5a6ce734c8f93e64f7fbecd0) (Incomplete)
 
## Relevant Research Papers
 - [Using Computer Vision to Solve Jigsaw Puzzles](https://web.stanford.edu/class/cs231a/prev_projects_2016/computer-vision-solve__1_.pdf)
 - [Apictorial Jigsaw Puzzles: The Computer Solution of a Problem in Pattern Recognition](http://ieeexplore.ieee.org/document/4038109/)
 - [A global approach to automatic solution of jigsaw puzzles](https://www.sciencedirect.com/science/article/pii/S0925772104000239)
 - [Solving jigsaw puzzles by computer](https://www.researchgate.net/publication/225796422_Solving_jigsaw_puzzles_by_computer)
