// Check if user is logged in
auth.onAuthStateChanged((user) => {
    if (user) {
        // User is signed in
        checkUserRole(user.uid);
    } else {
        // User is signed out
        window.location.href = 'login.html';
    }
});

// Check if user is an employee
async function checkUserRole(uid) {
    try {
        const userDoc = await db.collection('Users').doc(uid).get();
        if (userDoc.exists && userDoc.data().state === 'Employee') {
            // User is an employee, allow access
            loadUserData(uid);
        } else {
            // User is not an employee, redirect to login
            auth.signOut();
            window.location.href = 'login.html';
        }
    } catch (error) {
        console.error('Error checking user role:', error);
        auth.signOut();
        window.location.href = 'login.html';
    }
}

// Load user data
async function loadUserData(uid) {
    try {
        const userDoc = await db.collection('Users').doc(uid).get();
        if (userDoc.exists) {
            const userData = userDoc.data();
            document.querySelector('.welcome').textContent = `Hello ${userData.name}!`;
            loadQueues(uid);
        }
    } catch (error) {
        console.error('Error loading user data:', error);
    }
}

// Sign out function
function signOut() {
    auth.signOut().then(() => {
        window.location.href = 'login.html';
    }).catch((error) => {
        console.error('Error signing out:', error);
    });
} 