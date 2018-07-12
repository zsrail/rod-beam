function primary_data = find_primary_data(prev_data, const)
    %{
     Solves for the rod's primary data (u and phi) at the current time step.
     Since this simulation currently ignores contact and the beam, the 
     linear system is simply solved using mldivide. 

     @param    prev_data       A struct with fields for the primary and
                               derived data of the previous time step. See
                               add_derived_data.m for a full list.
     @param    const           A struct with the field num_nodes containg
                               the number of nodes on the rod's domain
                               (counting nodes at y=0 and y=Ly as well as
                               all interior nodes).
     @return    data    A struct containing the system's primary data 
                        (u, phi, theta, and w) at the current time-step.
                        Can be passed to any function in this project with
                        a primary_data parameter.
    %}
    f = [prev_data.f1; prev_data.f2];
    partial_inversion = prev_data.rod_matrix\[f, [1; zeros(length(f)-1, 1)]];
    f_star = partial_inversion(:, 1);
    I_1 = partial_inversion(:, 2);
    
    sigma_db = [1/I_1(1), -1/I_1(1)*f_star(1)]; % Represents sigma_db = 1/a*Wn - 1/a*f_star(1)
    primary_data = find_beam_data(prev_data, const, sigma_db);
    sigma_db = sigma_db*[primary_data.w(end); 1]; % Calculate actual scaler value of sigma_db
    u = f_star + sigma_db*I_1; 

    % split primary data into vectors for u and phi
    primary_data.u = u(1:const.num_nodes);
    primary_data.phi = u(const.num_nodes+1:end);
