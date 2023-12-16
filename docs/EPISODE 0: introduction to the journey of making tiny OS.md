![image](https://github.com/flydeoo/mya/assets/41344995/230032c0-0601-4e0c-a810-74adaccf5e1b)


It is not easy for me to say “Hey, let’s make OS” and I’m not going to say that. Instead, I want to share the journey of attempting to understand how OS works and how I can make a tiny one ( just for fun and practicing programming ) myself.



I think the first spark was a GitHub repo named “[build-your-own-x](https://github.com/codecrafters-io/build-your-own-x)”. The repository contained a list of interesting projects like ‘build your own shell’, ‘text editor’, and more.

While browsing through this repository, I bumped into an interesting project that caught my attention: “[writing a Tiny x86 Bootloader](https://www.joe-bergeron.com/posts/Writing%20a%20Tiny%20x86%20Bootloader/)”

Although I found it interesting, but at the time I didn’t know assembly language. I tried to understand what Joe Bergeron was saying in his blog, but I realized that maybe this was not the time. So, I put it aside for later.

A few months later, I found a YouTube video that explained how things work, what is assembler, compiler and object files. I followed the video lessons until I became somehow fluent in writing assembly programs. The lessons also talked about the C programming language and how to call an assembly function from a C program and vice versa.

That’s when I started C programming, and I liked it. I began to understand how a C program works by compiling it with a compiler argument that produces the assembly code of the program. This way, I figured out how things in C are implemented. For example, I wanted to know how function arguments are passed to a function in C, so I wrote a program in C and then generated an assembly file of the program. By looking at the assembly file, I was able to understand how things are done.

Obviously, I didn’t watch all the lessons from that YouTube tutorial, I only grabbed what I thought I needed. So at this point, I continued to learn new things by watching and learning from various online resources, but I needed a platform to practice what I had learned.

That’s when I discovered “[exercism](https://exercism.org/)” website which offered both assembly and C practices.

At first, I realized that I know nothing about c and assembly and till today I have the same Idea. but practicing and solving challenges on this site made me read more, note more, and debug more!

After spending time on solving exercises on the exercism, while I solved 54 percent of assembly challenges and 20 percent of c challenges, I thought it’s a good idea to come back to the bootloader article and read it again and test if I understand it or not. (it is worth saying that meanwhile, I did some leetcode via c, and yeah it’s helpful for me)

I make a long story, short. Yes, I did read it, and although it was not easy for me to understand some concepts and there were some conflicts with my understanding of how computer works… somehow I managed to make small steps towards understanding new things, revise old knowledge, test ideas, and …

after I implemented the bootloader, I saw the nano byte channel on YouTube which developed OS. By watching his videos the second spark happened. I followed his YouTube channel and learned many things from him.

There are tons of things that I learned in this journey and for me, the best moment was switching from assembly to c. it’s like running a C program on bare metal, without any OS, without c runtime, without c libraries.

![first sight of C program on bare metal](https://github.com/flydeoo/mya/assets/41344995/b41fb3f0-2f79-45c8-8567-83084ac92936)



In conclusion, the journey of attempting to understand how operating systems work and building a small one can be a challenging but rewarding experience. Along the way, I discovered many resources such as:

Operating Systems: Three Easy Pieces article on: https://pages.cs.wisc.edu/~remzi/OSTEP/

Linkers and Loaders book by John R. Levine

My dearest friend osdev website: https://wiki.osdev.org

and many other resources that I don’t remember them. (sorry)



Thanks for reading. Stay tuned for next episode.
