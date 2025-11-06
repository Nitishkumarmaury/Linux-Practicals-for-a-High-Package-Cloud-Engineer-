# Practical 3: Managing Project Teams with Users & Groups

## Objective
Implement proper user access controls and permissions for a development team using Linux users and groups.

## Steps Overview
1. Create Groups
2. Add Users
3. Set Up Project Directory
4. Configure Permissions
5. Test Access Control

## Detailed Steps

### 1. Create Groups
```bash
# Create developers group
sudo groupadd developers

# Create testers group
sudo groupadd testers
```

### 2. Add Users
```bash
# Create developer user
sudo adduser dev_user --gecos "Dev User" --disabled-password
sudo usermod -aG developers dev_user

# Create tester user
sudo adduser test_user --gecos "Test User" --disabled-password
sudo usermod -aG testers test_user
```

### 3. Set Up Project Directory
```bash
# Create project directory
sudo mkdir -p /opt/my_project

# Set ownership
sudo chown root:developers /opt/my_project

# Set permissions with setgid bit
sudo chmod 2775 /opt/my_project
```

### 4. Test Access
```bash
# Switch to dev user
su - dev_user

# Test file creation
touch /opt/my_project/test.txt

# Check file ownership
ls -l /opt/my_project/test.txt
```

## Permission Structure Explained

### Directory Permissions (2775)
- 2: SetGID bit
- 7: Owner permissions (read/write/execute)
- 7: Group permissions (read/write/execute)
- 5: Others permissions (read/execute)

### File Inheritance
- New files inherit group ownership
- Collaboration within groups is simplified
- Maintains security boundaries

## Access Control Matrix

| Resource | Developers | Testers | Others |
|----------|------------|---------|---------|
| Project Dir | Read/Write/Execute | Read/Execute | Read/Execute |
| New Files | Read/Write | Read | Read |
| Config Files | Read/Write | Read | None |

## Common Issues and Solutions

1. **Permission Denied**
   - Verify user group membership
   - Check directory permissions
   - Confirm ownership settings

2. **Group Inheritance Issues**
   - Verify SetGID bit
   - Check parent directory permissions
   - Confirm group membership

3. **Access Problems**
   - Review user/group assignments
   - Check file permissions
   - Verify directory structure

## Best Practices
1. Follow principle of least privilege
2. Use groups for access management
3. Document permission schemes
4. Regular access audits
5. Maintain consistent ownership

## Security Considerations
1. Regular permission audits
2. Proper password policies
3. Group membership reviews
4. File system monitoring
5. Access logging

## User Management Commands
```bash
# List group members
getent group developers

# Check user groups
groups dev_user

# Modify user groups
sudo usermod -aG new_group username

# Remove from group
sudo gpasswd -d username groupname
```

## File Permission Commands
```bash
# Change ownership
sudo chown user:group file

# Recursive permission change
sudo chmod -R 2775 directory

# Change group
sudo chgrp developers directory
```

## Verification Checklist
- [ ] Groups created successfully
- [ ] Users added to correct groups
- [ ] Project directory created
- [ ] Permissions set correctly
- [ ] SetGID bit configured
- [ ] Access testing completed

## Monitoring and Maintenance

### Regular Tasks
1. Audit user accounts
2. Review group memberships
3. Check directory permissions
4. Update documentation
5. Verify access controls

### Logging and Monitoring
1. Monitor file access
2. Track permission changes
3. Audit user activities
4. Review security logs

## Additional Recommendations
1. Implement sudo policies
2. Set up ACLs if needed
3. Configure user quotas
4. Document procedures
5. Train team members

## Troubleshooting Tips
1. Use `ls -l` to verify permissions
2. Check effective permissions with `namei -l`
3. Verify group membership with `id`
4. Test access with affected users
5. Review system logs