# Groff Bash Scripts
This is a collection of, as the name implies, bash scripts to make groff usage easier.
## Notes
I use groff to PDF which differs from the base groff installation by allowing use of the -T flag
```bat
groff -ms -T PDF example.ms > example.pdf
```
The groff to PDF package can be obtained by running
```bat
sudo apt install groff
```
replacing "apt" with your local package manager. This also works on MACOS with "brew".
All included scripts have lines commented on what to replace if you are using different software. Edit to meet your needs!
# References
- the **grofftoPDF** file is an edited version of the code on Josh8's wonderful groff formatting page. Find the original [here](https://josh8.com/blog/typesetting_with_groff.html)
