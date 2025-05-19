// Load queues for the employee
async function loadQueues(employeeId) {
    try {
        // Initial load of queues
        const queuesSnapshot = await db.collection('Queues')
            .where('idEmployee', '==', employeeId)
            .get();

        const queueButtonsContainer = document.querySelector('.queue-buttons-container');
        queueButtonsContainer.innerHTML = '';

        queuesSnapshot.forEach(doc => {
            updateQueueData(doc.id, doc.data());
        });

        // Add event listener to sign out button
        document.querySelector('.signout-btn').addEventListener('click', signOut);

        // Set up real-time listeners
        setupRealtimeListeners(employeeId);
    } catch (error) {
        console.error('Error loading queues:', error);
    }
}

// Set up real-time listeners
function setupRealtimeListeners(employeeId) {
    // Listen for queue changes (additions, deletions, modifications)
    db.collection('Queues')
        .where('idEmployee', '==', employeeId)
        .onSnapshot((snapshot) => {
            const queueButtonsContainer = document.querySelector('.queue-buttons-container');
            
            // Handle document changes
            snapshot.docChanges().forEach((change) => {
                if (change.type === 'added') {
                    // New queue added
                    updateQueueData(change.doc.id, change.doc.data());
                } else if (change.type === 'modified') {
                    // Queue modified
                    updateQueueData(change.doc.id, change.doc.data());
                } else if (change.type === 'removed') {
                    // Queue deleted
                    const button = document.querySelector(`[data-queue-id="${change.doc.id}"]`);
                    if (button) {
                        button.remove();
                    }
                    // If the deleted queue was selected, clear the display
                    if (document.querySelector('.queue-button.active')?.getAttribute('data-queue-id') === change.doc.id) {
                        document.querySelector('.current-number').textContent = '-';
                        document.querySelector('.queue-column').innerHTML = '';
                    }
                }
            });
        });
}

// Update queue data including customer count
async function updateQueueData(queueId, queue) {
    try {
        // Get active customers count
        const activeCustomers = await db.collection('Queues')
            .doc(queueId)
            .collection('Client')
            .where('status', '==', 'Active')
            .get();

        const activeCount = activeCustomers.size;

        // Update or create queue button
        let button = document.querySelector(`[data-queue-id="${queueId}"]`);
        if (!button) {
            button = document.createElement('button');
            button.className = 'queue-button';
            button.setAttribute('data-queue-id', queueId);
            button.onclick = () => selectQueue(queueId);
            document.querySelector('.queue-buttons-container').appendChild(button);
        }

        button.innerHTML = `
            <div class="queue-name">
                <span class="queue-icon">⏹️</span>
                <span class="queue-name-text">${queue.name}</span>
            </div>
            <div class="queue-count">${activeCount} Customers</div>
        `;

        // If this is the currently selected queue, update the current number
        const activeButton = document.querySelector('.queue-button.active');
        if (activeButton && activeButton.getAttribute('data-queue-id') === queueId) {
            // Check if there are any active customers
            if (activeCount === 0) {
                document.querySelector('.current-number').textContent = '-';
            } else {
                document.querySelector('.current-number').textContent = queue.Currentnumber;
            }
        }
    } catch (error) {
        console.error('Error updating queue data:', error);
    }
}

// Select queue and load its data
async function selectQueue(queueId) {
    try {
        // Remove active class from all buttons
        const buttons = document.querySelectorAll('.queue-button');
        buttons.forEach(button => button.classList.remove('active'));
        
        // Add active class to clicked button
        event.currentTarget.classList.add('active');

        // Load queue data
        const queueDoc = await db.collection('Queues').doc(queueId).get();
        const queue = queueDoc.data();

        // Update current number
        document.querySelector('.current-number').textContent = queue.Currentnumber;

        // Set up real-time listener for current number
        db.collection('Queues').doc(queueId)
            .onSnapshot((doc) => {
                if (doc.exists) {
                    document.querySelector('.current-number').textContent = doc.data().Currentnumber;
                }
            });

        // Load clients
        loadClients(queueId);

        // Generate QR code and show queue code
        generateQRCode(queueId, queue.code);
    } catch (error) {
        console.error('Error selecting queue:', error);
    }
}

// Create queue item
function createQueueItem(client, currentNumber) {
    const item = document.createElement('div');
    // Set color based on if customer's number matches current number and is active
    const isCurrent = client.yourPlace === currentNumber && client.status === 'Active';
    item.className = 'queue-item';
    item.style.backgroundColor = isCurrent ? '#2CD87D' : '#872CD8';
    item.setAttribute('data-number', client.yourPlace);
    item.setAttribute('data-status', client.status);
    
    item.innerHTML = `
        <span class="queue-name">${client.name}</span>
        <span class="queue-number">${client.yourPlace}</span>
    `;

    return item;
}

// Load clients for a queue
async function loadClients(queueId) {
    try {
        // Set up real-time listener for clients
        const queueDoc = await db.collection('Queues').doc(queueId).get();
        let currentNumber = queueDoc.data().Currentnumber;

        // Set up listener for active customers
        const activeClientsListener = db.collection('Queues')
            .doc(queueId)
            .collection('Client')
            .where('status', '==', 'Active')
            .orderBy('yourPlace')
            .limit(5)
            .onSnapshot((snapshot) => {
                const queueColumn = document.querySelector('.queue-column');
                queueColumn.innerHTML = '';

                // Update customer count in queue button
                const activeCount = snapshot.size;
                const queueButton = document.querySelector(`[data-queue-id="${queueId}"]`);
                if (queueButton) {
                    queueButton.querySelector('.queue-count').textContent = `${activeCount} Customers`;
                }

                // If no active customers, show dash for current number
                if (activeCount === 0) {
                    document.querySelector('.current-number').textContent = '-';
                }

                // Get all active customers
                const activeCustomers = snapshot.docs.map(doc => doc.data());
                
                // If current customer is no longer active, update to next customer
                const currentCustomerExists = activeCustomers.some(c => c.yourPlace === currentNumber);
                if (!currentCustomerExists && activeCustomers.length > 0) {
                    // Find the next customer in line
                    const nextCustomer = activeCustomers[0];
                    currentNumber = nextCustomer.yourPlace;
                    
                    // Update the current number in the queue document
                    db.collection('Queues').doc(queueId).update({
                        Currentnumber: currentNumber
                    });
                }

                snapshot.forEach(doc => {
                    const client = doc.data();
                    const queueItem = createQueueItem(client, currentNumber);
                    queueColumn.appendChild(queueItem);
                });

                // Re-add QR code container after clearing the queue column
                generateQRCode(queueId, queueDoc.data().code);
            });

        // Listen for changes in current number to update colors
        const currentNumberListener = db.collection('Queues').doc(queueId)
            .onSnapshot((doc) => {
                if (doc.exists) {
                    currentNumber = doc.data().Currentnumber;
                    const queueItems = document.querySelectorAll('.queue-item');
                    
                    // Get all active customers
                    db.collection('Queues')
                        .doc(queueId)
                        .collection('Client')
                        .where('status', '==', 'Active')
                        .get()
                        .then((activeSnapshot) => {
                            const activeCustomers = activeSnapshot.docs.map(doc => doc.data());
                            
                            queueItems.forEach(item => {
                                const itemNumber = parseInt(item.getAttribute('data-number'));
                                const itemStatus = item.getAttribute('data-status');
                                const customer = activeCustomers.find(c => c.yourPlace === itemNumber);
                                
                                // Only turn green if customer is active and matches current number
                                const shouldBeGreen = itemNumber === currentNumber && 
                                                    itemStatus === 'Active' && 
                                                    customer && 
                                                    customer.status === 'Active';
                                
                                item.style.backgroundColor = shouldBeGreen ? '#2CD87D' : '#872CD8';
                            });
                        });
                }
            });

        // Clean up listeners when queue changes
        return () => {
            activeClientsListener();
            currentNumberListener();
        };
    } catch (error) {
        console.error('Error loading clients:', error);
    }
}

// Generate QR code
function generateQRCode(queueId, queueCode) {
    const queueColumn = document.querySelector('.queue-column');
    
    // Create or get QR code container
    let qrCodeContainer = document.querySelector('.qr-code-container');
    if (!qrCodeContainer) {
        qrCodeContainer = document.createElement('div');
        qrCodeContainer.className = 'qr-code-container';
        queueColumn.appendChild(qrCodeContainer);
    }

    // Clear previous QR code
    qrCodeContainer.innerHTML = '';

    // Create QR code element
    const qrElement = document.createElement('div');
    qrElement.id = 'qrcode';
    qrCodeContainer.appendChild(qrElement);

    // Generate QR code using the queue code instead of ID
    new QRCode(qrElement, {
        text: queueCode || '',  // Use queue code for QR code content
        width: 200,
        height: 200,
        colorDark: "#000000",
        colorLight: "#ffffff",
        correctLevel: QRCode.CorrectLevel.H
    });

    // Add queue code text
    const codeText = document.createElement('p');
    codeText.innerHTML = `Code : <span style="color: #872CD8; font-weight: bold;">${queueCode || ''}</span>`;
    codeText.style.fontSize = '24px';
    codeText.style.marginTop = '20px';
    qrCodeContainer.appendChild(codeText);
} 