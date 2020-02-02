# Comp-Org-Project
During my fall semester of 2019, me and two other people were tasked with creating both a single-cycle and pipelined implementation of a processor using a reduced version of the LEGv8 instruction set. This project was to be done entirely in VHDL, with a paper and PowerPoint presentation to be done providing information on the created processor. Due to the increased workload from my other classes and my position as a teachning assistant, I was required to do the vast majority of the programming portion of the project over Thanksgiving break despite my effors to being the project earlier (my groupmates did the presentation and the paper, thankfully). As such, only the single-cycle implementation worked completely: the pipelined implementation, while nearly done, has some issues regarding reading and writing to the register file in the same cycle (although there are likely other latent issues).

I decided to upload this project now, as opposed to while the project was in progress, for several reasons:
1. I was very busy and I had no time to fool with uploading to Github
2. Other groups had the exact same project as us, and I didn't want to risk my work being plagiarized
3. I didn't know how well we would do on the project, and I wanted to know the final grade before posting

I'm uploading this now, as opposed to last December because of the following:
1. I finally have time to think and do things besides constantly work as a TA and in busy classes.
2. I'm working on a VGA driver in VHDL, and I might want to add a CPU to my design to do some cool stuff
3. I still don't know our grade for the project because it was never posted
4. I put a lot of work into this project and I would like to save what I did in case I ever want to look back on it later

As you may have noticed, this project still remains ungraded even though I received an A in the class. This appears to be the case for everyone who took the class--while our group appeared to be ahead of most groups in that the pipelined processor was at least mostly complete, nobody appears to have received a grade for the project. The teacher's internal gradebook likely contains the remakrs regarding our presentation, but no grading rubric/scale was ever posted for the project to my knowledge.

Thanks to Noel for making the register file, and to Sam and Noel for helping me debug the pipelined processor and making the presentation and paper.
