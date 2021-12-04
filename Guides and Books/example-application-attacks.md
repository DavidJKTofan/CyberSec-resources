# Examples of Application Attacks

* * * * * * 

## Privilege Escalation

Obtaining elevated privileges (i.e. Administrator or Root) on the target.

* Dump the SAM (local accounts file) 
* Retrieve /etc/passwd file 
* Look for insecure file shares 
* DLL pre-loading 
* Insecure or weak security on processes

Many vulnerabilities enable an attacker to gain system-level permissions.

### Examples

```
cat /etc/passwd | cut –d: -f1
```

```
pinjector.exe –p <PID of the account you want to mimick permissions from> cmd.exe <port>
```

## Cross Site Scripting (XSS)

Techniques used to hijack sessions:

* Can be **non-persistent** (emails, instant messages, blog posts, etc.) 
* **DOM-based**, which can be persistent or non-persitent
* **Persistent** (server-based) where an attacker doesn't need to actively target a user

### Examples

```
const script = document.createElement('script')
script.innerHTML = 'alert("hacked!")'
document.body.appendChild(script)
```

## SQL Injection

Modifying the SQL query that's passed to web application, SQL server, etc.

Adding code into a data stream: 

* Bypass login screens
* Vulnerable websites return usernames, passwords, etc., with the right SQL injection 
* Cause the application to "throw" an error and crash (allowing an attacked remote access)

### Examples

`USERNAME'#`

`" or ""="`

`105; DROP TABLE TABLENAME`

## DLL Injection

DLL Injection is a process of inserting code into a running process: 
* Attach to the process 
* Allocate Memory within the process 
* Copy the DLL or the DLL Path into the processes memory and determine appropriate memory addresses 
* Instruct the process to execute your DLL

DLL Inejction attacks can be created manually pr Pen Testing Tools like Metasploit can automate the process.

## LDAP Injection

Lightweight Directory Access Protocol (LDAP):

* "Address Book" of user accounts used to authenticate users 
* Identifies level of access, group memberships, etc.

Similar to SQL Injection attacks in that the query that is passed to the web server is modified to include malicious query statements or code.

### Examples

```
"value)(injected_filter"
"value)(injected_filter))(&(1=0"
```

```
(&(attribute=value)(second_filter))
(|(attribute=value)(second_filter))
```

## XML Injection

Attach technique that manipulates the logic of an XML application or service.

Form Input Example:
`<input type="text" size=20 name="userName">Insert the username</input>`
Underlying Code:
```
String ldapSearchQuery = "(cn=" + $userName + ")"; 
    System.out.println(ldapSearchQuery);
```
String passed from the web browser:
`"crees) (| (password = * ) )"`

* Could be used to inject XML into a statement that alters a path to file to disclose sensitive information.

```
<?xml version="1.0"?> 
<!DOCTYPE results [<!ENTITY harmless SYSTEM 
    "file:///var/www/config.ini">]>
    
<results>
    <results>&harmless;</results>
</results>
```

### Examples

```
http://example.com/add_to_cart.php?itemId=5"+perItemPrice="0.00"+quantity="100"+/><item+id="5&quantity=0
```

```
http://www.example.com/create_user.php?name=thomas&password=hfdj7!dn&mail=thomas@mail.com
```

```
<?xml  version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE foo [
   <!ELEMENT foo ANY >
   <!ENTITY xxe SYSTEM  "file:///dev/random" >]>
<foo>&xxe;</foo>
```

```
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE foo [
  <!ELEMENT foo ANY >
  <!ENTITY xxe SYSTEM "file:///etc/passwd" >]>
<foo>&xxe;</foo>
```

## Pointer Dereference

Vulnerability that can cause an application to throw an exception error, which typically results in the application crashing: 
* Can be leverage for a DoS attack against the entire sytem 
* Remote code execution

C/C++, Assembly or any other language that uses pointers is potentially vulnerable to this type of attack.

## Directory Traversal / Command Injection

Attack that manipulates user input to cause the application to traverse a directory structure and access files not intended to be visible:
* known as the `../` or "dot slash" attack 
* Directory climbing 
* Backtracking

## Buffer Overflow

Causes a system or app to crash or behave unexpectedly:
* Writing more data than the buffer can handle 
* Data is written to adjacent memory 

Calls or pointers to jump to a different address that was intended:
* Can contain user executable code which could allow remote code execution

## Race Conditions

A race condition occurs when a pair of routine programming calls in an application do not perform in the sequential manner that was intended:
* Potential security vulnerability if the calls are not performed in the correct order

Potential Vulnerabilities:
* Authentication: Trust may be assigned to an entity who is not who it claims to be 
* Integrity: Data from an untrusted (and possibly malicious) source may be integrated 
* Confidentiality: Data may be disclosed to an entity impersonating a trusted entity, resulting in information disclosure

## Time of Check

Type of race condition:
* Attacker is able to gain access prior to an authentication check
* Inserts code or alters authentication to disrupt normal authentication processes 
* Administrator see the intrusion, reset passwords, etc, but the attacker may still have access
    * Attacker could remain logged in with old credentials

Also referred to as Time of Check to Time of Use.

## Secure Conding Concepts, Error Handling, Input Validation

Application development is often a balancing act between time to market and security 
* Building for security adds to development time 
* Critical – if you don't have time to find the vulnerabilities, the bad guys will

Security mindset in programming:
* Error and exception handling
    * What does the application do when it encounters an error? Does it continue running, restart a process or module, or completely crash? If it crashes, does it give an attacker elevated privileges?
* Input validation
    * Validate/sanitize what is entered at the client side and/or server side before it's processed 
    * Mitigate attacks such as Cross Site Scripting (XSS) 
    * SQL Injection attacks

[Open Web Application Security Project (OWASP) – Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/migrated_content)

[CERT – Secure Coding](https://www.sei.cmu.edu/our-work/secure-development/index.cfm)

## Replay Attacks

Sniffing the wired or wireless network, a replay attack captures packets and puts them back on the wire
* Packets can potentially be modified and retransmitted to look like legitimate packets

Sequencing helps mitigate the effectiveness of this type of attack

## Integer Overflow

Integer overflow condition occurs when the result of an arithmetic operation exceeds the maximum size of integer type used to store it. 

When the overflow occurs, the interpreted value appears to "warp around" the max value and start at the min value:
* Could allow transactions to be reversed (i.e. money sent instead of received)

## Cross Site Request Forgery (XSRF)

Exploiting a website's trust in a user (application, IP address, etc) 
* Often referred to as one-click attack or session riding: CSRF or "See-Surf"

Requires victim to have recently visited the target website and have a valid cookie (not expired).

Difference between XSRF and XSS attacks:
* In an XSS attack, the browser runs malicious code because it was server from a site it trusts 
* In an XSRF attack, the server performs an action because it was sent a request from a client it trust

## API Attacks

Application Programming Interfact (API)

## Resource Exhaustion

## Memory Leak

## SSL Stripping

## Shimming

## Refactoring

## Pass the Hash

* * * * * * 

# Disclaimer

Educational purposes only. Source of information is publicly and/or freely available online.
